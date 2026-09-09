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

# RDS instance statuses that StartDBInstance actually accepts. Anything else that
# isn't already "available" is treated as mid-transition: don't re-issue the call,
# just wait it out (see _rds_disposition).
_RDS_STARTABLE = {
    "stopped",
    "inaccessible-encryption-credentials-recoverable",
    "incompatible-network",
}


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


def _ec2_instance_states(instance_ids):
    states = {}
    response = ec2.describe_instances(InstanceIds=instance_ids)
    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:
            states[instance["InstanceId"]] = instance["State"]["Name"]
    return states


def start_nat_instances(identifiers):
    results = []
    instance_ids = _resolve_nat_instance_ids(identifiers)
    if not instance_ids:
        logger.info("nat: no instances resolved from %s, skipping", identifiers)
        return results

    states = _ec2_instance_states(instance_ids)
    to_start = []
    for instance_id in instance_ids:
        if states.get(instance_id) == "running":
            logger.info("nat: %s already running, skipping", instance_id)
            results.append(
                {
                    "instance_ids": [instance_id],
                    "status": "running",
                    "skipped": "already running",
                }
            )
        else:
            to_start.append(instance_id)
    if not to_start:
        return results

    logger.info("nat: starting %s", to_start)
    try:
        ec2.start_instances(InstanceIds=to_start)
        ec2.get_waiter("instance_running").wait(
            InstanceIds=to_start,
            WaiterConfig={"Delay": 15, "MaxAttempts": 12},
        )
        logger.info("nat: %s running", to_start)
        results.append({"instance_ids": to_start, "status": "running"})
    except Exception as exc:  # noqa: BLE001 - surfaced in the response, not raised
        logger.error("nat: failed to start %s: %s", to_start, exc)
        results.append({"instance_ids": to_start, "error": str(exc)})
    return results


def stop_nat_instances(identifiers):
    results = []
    instance_ids = _resolve_nat_instance_ids(identifiers)
    if not instance_ids:
        logger.info("nat: no instances resolved from %s, skipping", identifiers)
        return results

    states = _ec2_instance_states(instance_ids)
    to_stop = []
    for instance_id in instance_ids:
        if states.get(instance_id) == "stopped":
            logger.info("nat: %s already stopped, skipping", instance_id)
            results.append(
                {
                    "instance_ids": [instance_id],
                    "status": "stopped",
                    "skipped": "already stopped",
                }
            )
        else:
            to_stop.append(instance_id)
    if not to_stop:
        return results

    logger.info("nat: stopping %s", to_stop)
    try:
        ec2.stop_instances(InstanceIds=to_stop)
        ec2.get_waiter("instance_stopped").wait(
            InstanceIds=to_stop,
            WaiterConfig={"Delay": 15, "MaxAttempts": 12},
        )
        logger.info("nat: %s stopped", to_stop)
        results.append({"instance_ids": to_stop, "status": "stopped"})
    except Exception as exc:  # noqa: BLE001
        logger.error("nat: failed to stop %s: %s", to_stop, exc)
        results.append({"instance_ids": to_stop, "error": str(exc)})
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


def _wait_for_instance_status(instance_id, target_status, delay=30, max_attempts=18):
    # botocore ships a db_instance_available waiter but no db_instance_stopped one,
    # so the stop transition has to be polled manually the same way clusters are.
    for attempt in range(1, max_attempts + 1):
        status = rds.describe_db_instances(
            DBInstanceIdentifier=instance_id
        )["DBInstances"][0]["DBInstanceStatus"]
        logger.info(
            "rds: %s status=%s (waiting for %s, attempt %s/%s)",
            instance_id, status, target_status, attempt, max_attempts,
        )
        if status == target_status:
            return
        time.sleep(delay)
    raise TimeoutError(
        f"{instance_id} did not reach status {target_status!r} after "
        f"{max_attempts * delay} seconds"
    )


def _db_cluster_status(cluster_id):
    return rds.describe_db_clusters(DBClusterIdentifier=cluster_id)["DBClusters"][0]["Status"]


def _db_instance_status(instance_id):
    return rds.describe_db_instances(
        DBInstanceIdentifier=instance_id
    )["DBInstances"][0]["DBInstanceStatus"]


def _rds_disposition(status, action):
    """Classify an RDS instance/cluster status for a start ("up") or stop ("down").

    - "satisfied":     already in the requested end state; skip the resource
                       entirely (no API call, no wait).
    - "act":           in a state the Start/Stop API accepts; issue the call,
                       then wait as before.
    - "transitioning": neither - already mid-transition ("starting", "stopping",
                       "backing-up", "modifying", ...). Don't re-issue the call.
                       "up" still waits for "available"; "down" just reports the
                       current status and moves on.
    """
    if action == "up":
        if status == "available":
            return "satisfied"
        if status in _RDS_STARTABLE:
            return "act"
        return "transitioning"
    if status == "stopped":
        return "satisfied"
    if status == "available":
        return "act"
    return "transitioning"


def start_rds(cluster_ids, instance_ids):
    results = []
    for cluster_id in cluster_ids:
        try:
            status = _db_cluster_status(cluster_id)
        except Exception as exc:  # noqa: BLE001
            logger.error("rds: failed to describe cluster %s: %s", cluster_id, exc)
            results.append({"cluster_id": cluster_id, "error": str(exc)})
            continue

        disposition = _rds_disposition(status, "up")
        if disposition == "satisfied":
            logger.info("rds: cluster %s already available, skipping", cluster_id)
            results.append(
                {"cluster_id": cluster_id, "status": "available", "skipped": "already available"}
            )
            continue

        logger.info("rds: starting cluster %s (status=%s)", cluster_id, status)
        try:
            if disposition == "act":
                rds.start_db_cluster(DBClusterIdentifier=cluster_id)
            _wait_for_cluster_status(cluster_id, "available")
            logger.info("rds: cluster %s available", cluster_id)
            results.append({"cluster_id": cluster_id, "status": "available"})
        except Exception as exc:  # noqa: BLE001
            logger.error("rds: failed to start cluster %s: %s", cluster_id, exc)
            results.append({"cluster_id": cluster_id, "error": str(exc)})

    for instance_id in instance_ids:
        try:
            status = _db_instance_status(instance_id)
        except Exception as exc:  # noqa: BLE001
            logger.error("rds: failed to describe instance %s: %s", instance_id, exc)
            results.append({"instance_id": instance_id, "error": str(exc)})
            continue

        disposition = _rds_disposition(status, "up")
        if disposition == "satisfied":
            logger.info("rds: instance %s already available, skipping", instance_id)
            results.append(
                {"instance_id": instance_id, "status": "available", "skipped": "already available"}
            )
            continue

        logger.info("rds: starting instance %s (status=%s)", instance_id, status)
        try:
            if disposition == "act":
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
        try:
            status = _db_cluster_status(cluster_id)
        except Exception as exc:  # noqa: BLE001
            logger.error("rds: failed to describe cluster %s: %s", cluster_id, exc)
            results.append({"cluster_id": cluster_id, "error": str(exc)})
            continue

        disposition = _rds_disposition(status, "down")
        if disposition == "satisfied":
            logger.info("rds: cluster %s already stopped, skipping", cluster_id)
            results.append(
                {"cluster_id": cluster_id, "status": "stopped", "skipped": "already stopped"}
            )
            continue
        if disposition == "transitioning":
            logger.info("rds: cluster %s status=%s, not stopping, skipping", cluster_id, status)
            results.append(
                {"cluster_id": cluster_id, "status": status, "skipped": f"status is {status!r}"}
            )
            continue

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
        try:
            status = _db_instance_status(instance_id)
        except Exception as exc:  # noqa: BLE001
            logger.error("rds: failed to describe instance %s: %s", instance_id, exc)
            results.append({"instance_id": instance_id, "error": str(exc)})
            continue

        disposition = _rds_disposition(status, "down")
        if disposition == "satisfied":
            logger.info("rds: instance %s already stopped, skipping", instance_id)
            results.append(
                {"instance_id": instance_id, "status": "stopped", "skipped": "already stopped"}
            )
            continue
        if disposition == "transitioning":
            logger.info("rds: instance %s status=%s, not stopping, skipping", instance_id, status)
            results.append(
                {"instance_id": instance_id, "status": status, "skipped": f"status is {status!r}"}
            )
            continue

        logger.info("rds: stopping instance %s", instance_id)
        try:
            rds.stop_db_instance(DBInstanceIdentifier=instance_id)
            _wait_for_instance_status(instance_id, "stopped")
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

        try:
            described = ecs.describe_services(cluster=cluster, services=[service])
        except Exception as exc:  # noqa: BLE001
            logger.error("ecs: failed to describe %s/%s: %s", cluster, service, exc)
            results.append({"cluster": cluster, "service": service, "error": str(exc)})
            continue

        current = described["services"][0] if described.get("services") else None
        if (
            current is not None
            and current["desiredCount"] == desired_count
            and current["runningCount"] == desired_count
            and current.get("pendingCount", 0) == 0
        ):
            logger.info(
                "ecs: %s/%s already at desired count %s, skipping", cluster, service, desired_count
            )
            results.append(
                {
                    "cluster": cluster,
                    "service": service,
                    "desired_count": desired_count,
                    "skipped": "already at desired count",
                }
            )
            continue

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
