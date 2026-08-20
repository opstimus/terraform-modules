import json
import os

import boto3

ACTION_ALIASES = {
    "up": "up",
    "start": "up",
    "on": "up",
    "down": "down",
    "stop": "down",
    "off": "down",
}

ec2 = boto3.client("ec2")
rds = boto3.client("rds")
ecs = boto3.client("ecs")


def _resolve_nat_instance_ids(identifiers):
    resolved = []
    for identifier in identifiers:
        if identifier.startswith("i-"):
            resolved.append(identifier)
            continue
        response = ec2.describe_instances(
            Filters=[{"Name": "tag:Name", "Values": [identifier]}]
        )
        for reservation in response["Reservations"]:
            for instance in reservation["Instances"]:
                resolved.append(instance["InstanceId"])
    return resolved


def start_nat_instances(identifiers):
    results = []
    instance_ids = _resolve_nat_instance_ids(identifiers)
    if not instance_ids:
        return results
    try:
        ec2.start_instances(InstanceIds=instance_ids)
        ec2.get_waiter("instance_running").wait(
            InstanceIds=instance_ids,
            WaiterConfig={"Delay": 15, "MaxAttempts": 12},
        )
        results.append({"instance_ids": instance_ids, "status": "running"})
    except Exception as exc:  # noqa: BLE001 - surfaced in the response, not raised
        results.append({"instance_ids": instance_ids, "error": str(exc)})
    return results


def stop_nat_instances(identifiers):
    results = []
    instance_ids = _resolve_nat_instance_ids(identifiers)
    if not instance_ids:
        return results
    try:
        ec2.stop_instances(InstanceIds=instance_ids)
        ec2.get_waiter("instance_stopped").wait(
            InstanceIds=instance_ids,
            WaiterConfig={"Delay": 15, "MaxAttempts": 12},
        )
        results.append({"instance_ids": instance_ids, "status": "stopped"})
    except Exception as exc:  # noqa: BLE001
        results.append({"instance_ids": instance_ids, "error": str(exc)})
    return results


def start_rds(cluster_ids, instance_ids):
    results = []
    for cluster_id in cluster_ids:
        try:
            rds.start_db_cluster(DBClusterIdentifier=cluster_id)
            rds.get_waiter("db_cluster_available").wait(
                DBClusterIdentifier=cluster_id,
                WaiterConfig={"Delay": 30, "MaxAttempts": 18},
            )
            results.append({"cluster_id": cluster_id, "status": "available"})
        except Exception as exc:  # noqa: BLE001
            results.append({"cluster_id": cluster_id, "error": str(exc)})
    for instance_id in instance_ids:
        try:
            rds.start_db_instance(DBInstanceIdentifier=instance_id)
            rds.get_waiter("db_instance_available").wait(
                DBInstanceIdentifier=instance_id,
                WaiterConfig={"Delay": 30, "MaxAttempts": 18},
            )
            results.append({"instance_id": instance_id, "status": "available"})
        except Exception as exc:  # noqa: BLE001
            results.append({"instance_id": instance_id, "error": str(exc)})
    return results


def stop_rds(cluster_ids, instance_ids):
    results = []
    for cluster_id in cluster_ids:
        try:
            rds.stop_db_cluster(DBClusterIdentifier=cluster_id)
            rds.get_waiter("db_cluster_stopped").wait(
                DBClusterIdentifier=cluster_id,
                WaiterConfig={"Delay": 30, "MaxAttempts": 18},
            )
            results.append({"cluster_id": cluster_id, "status": "stopped"})
        except Exception as exc:  # noqa: BLE001
            results.append({"cluster_id": cluster_id, "error": str(exc)})
    for instance_id in instance_ids:
        try:
            rds.stop_db_instance(DBInstanceIdentifier=instance_id)
            rds.get_waiter("db_instance_stopped").wait(
                DBInstanceIdentifier=instance_id,
                WaiterConfig={"Delay": 30, "MaxAttempts": 18},
            )
            results.append({"instance_id": instance_id, "status": "stopped"})
        except Exception as exc:  # noqa: BLE001
            results.append({"instance_id": instance_id, "error": str(exc)})
    return results


def set_ecs_desired_count(services, desired_count_override=None):
    results = []
    for svc in services:
        cluster = svc["cluster"]
        service = svc["service"]
        desired_count = (
            0 if desired_count_override == 0 else svc.get("desired_count", 0)
        )
        try:
            ecs.update_service(
                cluster=cluster, service=service, desiredCount=desired_count
            )
            ecs.get_waiter("services_stable").wait(
                cluster=cluster,
                services=[service],
                WaiterConfig={"Delay": 15, "MaxAttempts": 12},
            )
            results.append(
                {"cluster": cluster, "service": service, "desired_count": desired_count}
            )
        except Exception as exc:  # noqa: BLE001
            results.append({"cluster": cluster, "service": service, "error": str(exc)})
    return results


def lambda_handler(event, context):
    raw_action = event.get("action", "")
    action = ACTION_ALIASES.get(str(raw_action).lower())
    if action is None:
        raise ValueError(f"Unrecognized action: {raw_action!r}")

    nat_instance_ids = json.loads(os.environ.get("NAT_INSTANCE_IDS", "[]"))
    rds_cluster_ids = json.loads(os.environ.get("RDS_CLUSTER_IDS", "[]"))
    rds_instance_ids = json.loads(os.environ.get("RDS_INSTANCE_IDS", "[]"))
    ecs_services = json.loads(os.environ.get("ECS_SERVICES", "[]"))

    summary = {"action": action, "nat": [], "rds": [], "ecs": []}

    if action == "up":
        summary["nat"] = start_nat_instances(nat_instance_ids)
        summary["rds"] = start_rds(rds_cluster_ids, rds_instance_ids)
        summary["ecs"] = set_ecs_desired_count(ecs_services)
    else:
        summary["ecs"] = set_ecs_desired_count(ecs_services, desired_count_override=0)
        summary["rds"] = stop_rds(rds_cluster_ids, rds_instance_ids)
        summary["nat"] = stop_nat_instances(nat_instance_ids)

    return summary
