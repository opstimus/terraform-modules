import json
import logging
import os
import time

import boto3

logger = logging.getLogger()
logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))

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


# Only instances in these states can be started or stopped. Terminated and
# shutting-down instances are skipped so that a name-tag lookup which still
# matches replaced NAT instances doesn't fail the whole StopInstances call.
_ACTIONABLE_STATES = ["pending", "running", "stopping", "stopped"]


def _resolve_nat_instance_ids(identifiers):
    resolved = []
    for identifier in identifiers:
        if identifier.startswith("i-"):
            resolved.append(identifier)
            continue
        response = ec2.describe_instances(
            Filters=[
                {"Name": "tag:Name", "Values": [identifier]},
                {"Name": "instance-state-name", "Values": _ACTIONABLE_STATES},
            ]
        )
        for reservation in response["Reservations"]:
            for instance in reservation["Instances"]:
                resolved.append(instance["InstanceId"])
    return resolved


def start_nat_instances(identifiers):
    results = []
    instance_ids = _resolve_nat_instance_ids(identifiers)
    if not instance_ids:
        logger.info("nat: no instances resolved from %s, skipping", identifiers)
        return results
    logger.info("nat: starting %s", instance_ids)
    try:
        ec2.start_instances(InstanceIds=instance_ids)
        ec2.get_waiter("instance_running").wait(
            InstanceIds=instance_ids,
            WaiterConfig={"Delay": 15, "MaxAttempts": 12},
        )
        logger.info("nat: %s running", instance_ids)
        results.append({"instance_ids": instance_ids, "status": "running"})
    except Exception as exc:  # noqa: BLE001 - surfaced in the response, not raised
        logger.error("nat: failed to start %s: %s", instance_ids, exc)
        results.append({"instance_ids": instance_ids, "error": str(exc)})
    return results


def stop_nat_instances(identifiers):
    results = []
    instance_ids = _resolve_nat_instance_ids(identifiers)
    if not instance_ids:
        logger.info("nat: no instances resolved from %s, skipping", identifiers)
        return results
    logger.info("nat: stopping %s", instance_ids)
    try:
        ec2.stop_instances(InstanceIds=instance_ids)
        ec2.get_waiter("instance_stopped").wait(
            InstanceIds=instance_ids,
            WaiterConfig={"Delay": 15, "MaxAttempts": 12},
        )
        logger.info("nat: %s stopped", instance_ids)
        results.append({"instance_ids": instance_ids, "status": "stopped"})
    except Exception as exc:  # noqa: BLE001
        logger.error("nat: failed to stop %s: %s", instance_ids, exc)
        results.append({"instance_ids": instance_ids, "error": str(exc)})
    return results


def _wait_for_cluster_status(cluster_id, target_status, delay=30, max_attempts=18):
    # RDS has no db_cluster_available / db_cluster_stopped waiters in botocore,
    # so cluster start/stop transitions must be polled manually.
    for attempt in range(1, max_attempts + 1):
        status = rds.describe_db_clusters(DBClusterIdentifier=cluster_id)["DBClusters"][0]["Status"]
        logger.info(
            "rds: %s status=%s (waiting for %s, attempt %s/%s)",
            cluster_id, status, target_status, attempt, max_attempts,
        )
        if status == target_status:
            return
        time.sleep(delay)
    raise TimeoutError(
        f"{cluster_id} did not reach status {target_status!r} after "
        f"{max_attempts * delay} seconds"
    )


def start_rds(cluster_ids, instance_ids):
    results = []
    for cluster_id in cluster_ids:
        logger.info("rds: starting cluster %s", cluster_id)
        try:
            rds.start_db_cluster(DBClusterIdentifier=cluster_id)
            _wait_for_cluster_status(cluster_id, "available")
            logger.info("rds: cluster %s available", cluster_id)
            results.append({"cluster_id": cluster_id, "status": "available"})
        except Exception as exc:  # noqa: BLE001
            logger.error("rds: failed to start cluster %s: %s", cluster_id, exc)
            results.append({"cluster_id": cluster_id, "error": str(exc)})
    for instance_id in instance_ids:
        logger.info("rds: starting instance %s", instance_id)
        try:
            rds.start_db_instance(DBInstanceIdentifier=instance_id)
            rds.get_waiter("db_instance_available").wait(
                DBInstanceIdentifier=instance_id,
                WaiterConfig={"Delay": 30, "MaxAttempts": 18},
            )
            logger.info("rds: instance %s available", instance_id)
            results.append({"instance_id": instance_id, "status": "available"})
        except Exception as exc:  # noqa: BLE001
            logger.error("rds: failed to start instance %s: %s", instance_id, exc)
            results.append({"instance_id": instance_id, "error": str(exc)})
    return results


def stop_rds(cluster_ids, instance_ids):
    results = []
    for cluster_id in cluster_ids:
        logger.info("rds: stopping cluster %s", cluster_id)
        try:
            rds.stop_db_cluster(DBClusterIdentifier=cluster_id)
            # Unlike start, don't wait for "stopped": Aurora cluster stop routinely
            # takes well over _wait_for_cluster_status's poll budget, so the wait
            # always timed out here anyway - it only burned Lambda time and reported
            # a spurious error for a stop that was in fact proceeding normally.
            logger.info("rds: cluster %s stopping (not waiting for terminal state)", cluster_id)
            results.append({"cluster_id": cluster_id, "status": "stopping"})
        except Exception as exc:  # noqa: BLE001
            logger.error("rds: failed to stop cluster %s: %s", cluster_id, exc)
            results.append({"cluster_id": cluster_id, "error": str(exc)})
    for instance_id in instance_ids:
        logger.info("rds: stopping instance %s", instance_id)
        try:
            rds.stop_db_instance(DBInstanceIdentifier=instance_id)
            rds.get_waiter("db_instance_stopped").wait(
                DBInstanceIdentifier=instance_id,
                WaiterConfig={"Delay": 30, "MaxAttempts": 18},
            )
            logger.info("rds: instance %s stopped", instance_id)
            results.append({"instance_id": instance_id, "status": "stopped"})
        except Exception as exc:  # noqa: BLE001
            logger.error("rds: failed to stop instance %s: %s", instance_id, exc)
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
        logger.info("ecs: setting %s/%s desired count to %s", cluster, service, desired_count)
        try:
            ecs.update_service(
                cluster=cluster, service=service, desiredCount=desired_count
            )
            ecs.get_waiter("services_stable").wait(
                cluster=cluster,
                services=[service],
                WaiterConfig={"Delay": 15, "MaxAttempts": 12},
            )
            logger.info("ecs: %s/%s stable at desired count %s", cluster, service, desired_count)
            results.append(
                {"cluster": cluster, "service": service, "desired_count": desired_count}
            )
        except Exception as exc:  # noqa: BLE001
            logger.error("ecs: failed to update %s/%s: %s", cluster, service, exc)
            results.append({"cluster": cluster, "service": service, "error": str(exc)})
    return results


def lambda_handler(event, context):
    raw_action = event.get("action", "")
    action = ACTION_ALIASES.get(str(raw_action).lower())
    if action is None:
        raise ValueError(f"Unrecognized action: {raw_action!r}")

    logger.info("request %s: action=%s (raw=%r)", context.aws_request_id, action, raw_action)

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

    logger.info("request %s: done - %s", context.aws_request_id, json.dumps(summary))
    return summary
