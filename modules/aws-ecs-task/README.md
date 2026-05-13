# ECS Task (Run-Once) Module

## Description

This Terraform module runs a one-shot ECS Fargate task synchronously from `terraform apply`. It wraps an existing task definition with a Step Functions state machine using the `ecs:runTask.sync` integration, plus a `null_resource` that starts the execution with a deterministic name (`<name>-rev-<revision>`) and polls `describe-execution` until terminal state. The apply succeeds only if the task's essential container exits 0; non-zero exit or any `RunTask` failure fails the apply.

Typical use cases: database migrations gating service deploys, schema seeds, one-shot data jobs, smoke tests against newly-provisioned infrastructure.

The module does NOT create the task definition — pass `task_definition_arn` in (use `terraform-aws-task-definition` or hand-roll one if you need `runtime_platform` or other options).

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.3.0 |
| aws       | >= 6.0   |
| null      | >= 3.0   |

The `terraform apply` host (CI runner or local) must have the AWS CLI on `PATH` and IAM permissions for `states:StartExecution` and `states:DescribeExecution` on the state machine this module creates.

## Providers

| Name | Version |
|------|---------|
| aws  | >= 6.0  |
| null | >= 3.0  |

## Inputs

| Name                    | Description                                                                                                                                                          | Type           | Default | Required |
|-------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|---------|:--------:|
| project                 | Project name                                                                                                                                                         | `string`       | `-`     | yes      |
| environment             | Environment name                                                                                                                                                     | `string`       | `-`     | yes      |
| name                    | Resource name suffix (e.g. `migrate`). Combined into `<project>-<environment>-<name>`.                                                                               | `string`       | `-`     | yes      |
| cluster_arn             | ARN of the ECS cluster the task runs in.                                                                                                                             | `string`       | `-`     | yes      |
| task_definition_arn     | ARN of the task definition to run, **including revision**. The revision is parsed to form a deterministic SFN execution name.                                        | `string`       | `-`     | yes      |
| task_execution_role_arn | ARN of the ECS task execution role (image pulls, secrets, logs).                                                                                                     | `string`       | `-`     | yes      |
| subnets                 | Subnets for the Fargate task (private subnets if the task needs RDS/internal access).                                                                                | `list(string)` | `-`     | yes      |
| security_groups         | Security groups for the Fargate task.                                                                                                                                | `list(string)` | `-`     | yes      |
| task_role_arn           | Task IAM role passed to the running container. When `null`, the module creates a role with SSM exec-channel permissions.                                             | `string`       | `null`  | no       |
| assign_public_ip        | Whether the Fargate task gets a public IP.                                                                                                                           | `bool`         | `false` | no       |
| timeout_seconds         | Maximum SFN execution duration **and** local-exec poll deadline. Both are bounded by this value.                                                                     | `number`       | `1800`  | no       |
| poll_interval_seconds   | Seconds between `describe-execution` polls in the wait loop.                                                                                                         | `number`       | `10`    | no       |
| execution_input         | JSON string passed as SFN execution input. Used as a label in the SFN console and as part of the idempotency key (same name + same input dedups). Default `"{}"`.    | `string`       | `"{}"`  | no       |
| tags                    | Tags applied to the IAM roles and state machine.                                                                                                                     | `map(string)`  | `{}`    | no       |

## Outputs

| Name               | Description                                                                                  |
|--------------------|----------------------------------------------------------------------------------------------|
| state_machine_arn  | ARN of the Step Function state machine.                                                      |
| state_machine_name | Name of the Step Function state machine.                                                     |
| task_role_arn      | Task role ARN in use — caller-supplied if `task_role_arn` was set, otherwise module-created. |

## Usage examples

### Basic — gate a service deploy on a Prisma migration

```hcl
resource "aws_ecs_task_definition" "migrate" {
  family                   = "myapp-stg-migrate"
  execution_role_arn       = data.aws_iam_role.task_execution.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 1024
  container_definitions    = jsonencode([{ /* ... prisma migrate deploy ... */ }])
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

module "migrate_task" {
  source = "github.com/opstimus/terraform-aws-ecs-task?ref=v<RELEASE>"

  project                 = "myapp"
  environment             = "stg"
  name                    = "migrate"
  cluster_arn             = data.aws_ecs_cluster.main.arn
  task_definition_arn     = aws_ecs_task_definition.migrate.arn
  task_execution_role_arn = data.aws_iam_role.task_execution.arn
  subnets                 = data.aws_subnets.private.ids
  security_groups         = [data.aws_security_group.ecs.id]
  execution_input         = jsonencode({ image_tag = var.image_tag })
}

module "ecs_service" {
  source = "github.com/opstimus/terraform-aws-ecs-service?ref=v<RELEASE>"
  # ...
  depends_on = [module.migrate_task]
}
```

### With caller-supplied task role

```hcl
module "migrate_task" {
  source = "github.com/opstimus/terraform-aws-ecs-task?ref=v<RELEASE>"

  project                 = "myapp"
  environment             = "stg"
  name                    = "migrate"
  cluster_arn             = data.aws_ecs_cluster.main.arn
  task_definition_arn     = aws_ecs_task_definition.migrate.arn
  task_execution_role_arn = data.aws_iam_role.task_execution.arn
  task_role_arn           = aws_iam_role.my_custom_task_role.arn
  subnets                 = data.aws_subnets.private.ids
  security_groups         = [data.aws_security_group.ecs.id]
}
```

## Notes

- **Deterministic execution name.** The SFN execution is named `<name>-rev-<revision>` (revision parsed from `task_definition_arn`). For Standard workflows, same name + same input is idempotent — so re-running an interrupted apply attaches to the in-flight execution rather than starting a duplicate. Across 90 days, names must be unique unless the input also matches.

- **Failure semantics.** `runTask.sync` fails the SFN execution (`States.TaskFailed`) when the essential container exits non-zero or `RunTask` returns failures (capacity, IAM, image pull). The `null_resource` polls until terminal state and `exit 1`s the local-exec on any non-`SUCCEEDED` status, which fails `terraform apply`.

- **Timeout matches on both sides.** `timeout_seconds` is wired into both the SFN's `TimeoutSeconds` (authoritative) and the bash `DEADLINE` (backstop for AWS CLI hangs). Bump them together if a migration needs more than 30 minutes.

- **AWS CLI credentials.** The local-exec uses whatever credentials the `terraform apply` host has. For CI, that's the assumed role from `configure-aws-credentials`. For local applies, your shell's `~/.aws/credentials`/`AWS_PROFILE`/`AWS_REGION`. The deploy role needs `states:StartExecution` and `states:DescribeExecution` on the state machine ARN.

- **The state machine is updated on every task-def revision** because its `TaskDefinition` parameter pins to the specific ARN (pinning is intentional — it eliminates a race where the SFN could pick up a stale "latest" revision between the task-def replace and the SFN run). Expect "1 to change" on the SFN whenever the task def changes.
