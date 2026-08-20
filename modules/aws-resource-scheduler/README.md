# Resource Scheduler Module

## Description

This Terraform module deploys a Lambda function that starts/stops cost-driving
infrastructure on demand: NAT EC2 instances, an Aurora cluster or standalone RDS
instance, and ECS services. It is meant to be invoked manually (e.g. from a GitHub
Actions `workflow_dispatch` in the consuming repo) — this module only creates the
Lambda, its IAM role, and its packaged code. It does not invoke the function itself
and does not create any schedule/trigger.

Two distinct actions, kept deliberately separate:

1. **Deploy** (`terraform apply`) — creates/updates the Lambda function, its IAM role,
   and its packaged code. Run only when this module's version or inputs change.
2. **Invoke** (`aws lambda invoke --payload '{"action":"up"|"down"}'`) — actually starts
   or stops the target resources. Run from the consuming repo's own workflow whenever
   someone wants the environment scaled up or down. Does not touch Terraform at all.

Behavior:

- The Lambda reads `event["action"]` and normalizes `up`/`start`/`on` → `"up"`,
  `down`/`stop`/`off` → `"down"`; anything else raises `ValueError`.
- `up` order: NAT → RDS → ECS (don't bring ECS up before its network/DB dependencies
  are ready). `down` order: ECS → RDS → NAT (drain ECS before the DB stops, keep NAT
  egress up the longest).
- Each resource type is only touched if its corresponding input list is non-empty; the
  IAM policy is scoped to match — e.g. no RDS permissions are granted if neither
  `rds_cluster_ids` nor `rds_instance_ids` is set.
- Every start/stop waits (bounded `boto3` waiter) for the resource to reach a ready
  state before moving to the next tier, budgeted to fit inside `var.timeout`. Per-
  resource errors are captured in the returned JSON summary rather than raised, so
  partial failures are visible in the invoke output instead of just crashing, and a
  re-run after a partial/timed-out invocation resumes cleanly.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.3.0 |
| aws       | >= 6.0   |
| archive   | >= 2.0   |

## Providers

| Name    | Version |
|---------|---------|
| aws     | >= 6.0  |
| archive | >= 2.0  |

## Inputs

| Name                | Description                                                    | Type           | Default              | Required |
|---------------------|------------------------------------------------------------------|----------------|-----------------------|:--------:|
| project             | Project name                                                    | `string`       | `-`                   | yes      |
| environment         | Environment name                                                 | `string`       | `-`                   | yes      |
| name                | Function/role name suffix                                       | `string`       | `"resource-scheduler"`| no       |
| nat_instance_ids    | EC2 instance IDs (`i-...`) or Name tags of NAT instances         | `list(string)` | `[]`                  | no       |
| rds_cluster_ids     | Aurora/RDS cluster identifiers to start/stop                     | `list(string)` | `[]`                  | no       |
| rds_instance_ids    | Standalone RDS instance identifiers to start/stop                | `list(string)` | `[]`                  | no       |
| ecs_services        | ECS `{cluster, service, desired_count}` entries to scale          | `list(object)` | `[]`                  | no       |
| timeout             | Lambda timeout in seconds (hard cap 900)                         | `number`       | `870`                 | no       |
| memory_size         | Memory allocated to the Lambda function (in MB)                  | `number`       | `128`                 | no       |
| log_retention_days  | CloudWatch log retention for the Lambda's log group               | `number`       | `30`                  | no       |
| tags                | Tags applied to the Lambda function                              | `map(string)`  | `{}`                  | no       |

## Outputs

| Name          | Description                                    |
|---------------|-------------------------------------------------|
| function_name | The name of the Lambda function                  |
| function_arn  | The ARN of the Lambda function                   |
| invoke_arn    | The ARN used to invoke the function              |
| role_arn      | The ARN of the Lambda's IAM execution role        |

## Usage example

```hcl
module "resource_scheduler" {
  source      = "git::https://github.com/opstimus/terraform-modules.git//modules/aws-resource-scheduler?ref=aws-resource-scheduler/v<RELEASE>"
  project     = "app-lite"
  environment = "dev"

  nat_instance_ids = ["app-lite-dev-nat"]
  rds_cluster_ids  = ["app-lite-dev-aurora"]

  ecs_services = [
    { cluster = "app-lite-dev", service = "api", desired_count = 2 },
    { cluster = "app-lite-dev", service = "worker", desired_count = 1 },
  ]

  tags = {
    Environment = "dev"
  }
}
```

Then, from the consuming repo's own `workflow_dispatch` workflow (this module does not
create one):

```yaml
- name: Turn environment up/down
  run: |
    aws lambda invoke \
      --function-name ${{ inputs.function_name }} \
      --payload '{"action": "${{ inputs.action }}"}' \
      --cli-binary-format raw-in-base64-out \
      response.json
    cat response.json
```

## Important considerations

- **No schedule/trigger is created.** This module is invoke-only by design — wire up
  `aws lambda invoke` from whatever automation (GitHub Actions `workflow_dispatch`,
  EventBridge, etc.) the consuming repo wants to drive it from.
- **`ecs_services` desired counts are static.** This module has no visibility into
  another repo's variables, so each service's "up" desired count must be spelled out
  explicitly and kept in sync by hand if the source-of-truth changes.
- **IAM role needs `lambda:InvokeFunction` grantable to whoever invokes it** — the role
  this module creates is the Lambda's *execution* role (what the function can do), not
  an invoke-permission grant for callers. Give your CI/CD identity `lambda:InvokeFunction`
  on the `function_arn` output separately.
- **`timeout` must stay under 900s** (Lambda's hard cap) and should be large enough to
  cover the slowest resource in the sequence — RDS/Aurora start/stop waiters alone can
  take up to ~9 minutes.
