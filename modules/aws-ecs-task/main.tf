data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  resource_name            = "${var.project}-${var.environment}-${var.name}"
  task_definition_revision = reverse(split(":", var.task_definition_arn))[0]
  task_definition_family   = trimsuffix(var.task_definition_arn, ":${local.task_definition_revision}")
  task_role_arn            = var.task_role_arn != null ? var.task_role_arn : aws_iam_role.task[0].arn
}

resource "aws_iam_role" "task" {
  count = var.task_role_arn == null ? 1 : 0
  name  = "${local.resource_name}-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "task" {
  count = var.task_role_arn == null ? 1 : 0
  name  = "${local.resource_name}-task"
  role  = aws_iam_role.task[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role" "sfn" {
  name = "${local.resource_name}-sfn"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "states.amazonaws.com" }
    }]
  })

  tags = var.tags
}

data "aws_iam_policy_document" "sfn" {
  statement {
    actions   = ["ecs:RunTask"]
    resources = ["${local.task_definition_family}:*"]
  }
  statement {
    actions   = ["ecs:StopTask", "ecs:DescribeTasks"]
    resources = ["*"]
  }
  statement {
    actions = ["iam:PassRole"]
    resources = [
      var.task_execution_role_arn,
      local.task_role_arn,
    ]
  }
  statement {
    actions = ["events:PutTargets", "events:PutRule", "events:DescribeRule"]
    resources = [
      "arn:aws:events:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:rule/StepFunctionsGetEventsForECSTaskRule"
    ]
  }
}

resource "aws_iam_role_policy" "sfn" {
  name   = "${local.resource_name}-sfn"
  role   = aws_iam_role.sfn.id
  policy = data.aws_iam_policy_document.sfn.json
}

resource "aws_sfn_state_machine" "main" {
  name       = local.resource_name
  role_arn   = aws_iam_role.sfn.arn
  depends_on = [aws_iam_role_policy.sfn]

  definition = jsonencode({
    StartAt = "RunTask"
    States = {
      RunTask = {
        Type     = "Task"
        Resource = "arn:aws:states:::ecs:runTask.sync"
        Parameters = {
          Cluster        = var.cluster_arn
          TaskDefinition = var.task_definition_arn
          LaunchType     = "FARGATE"
          NetworkConfiguration = {
            AwsvpcConfiguration = {
              Subnets        = var.subnets
              SecurityGroups = var.security_groups
              AssignPublicIp = var.assign_public_ip ? "ENABLED" : "DISABLED"
            }
          }
        }
        TimeoutSeconds = var.timeout_seconds
        Retry          = [{ ErrorEquals = ["States.TaskFailed"], MaxAttempts = 0 }]
        End            = true
      }
    }
  })

  tags = var.tags
}

# Same name+input dedups in SFN within 90 days — safe to re-run interrupted applies.
resource "null_resource" "run" {
  triggers = {
    task_definition_arn = var.task_definition_arn
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      set -euo pipefail

      EXEC_NAME="${var.name}-rev-${local.task_definition_revision}"
      INPUT='${var.execution_input}'

      echo "Starting Step Function execution: $EXEC_NAME"
      EXEC_ARN=$(aws stepfunctions start-execution \
        --region "${data.aws_region.current.region}" \
        --state-machine-arn "${aws_sfn_state_machine.main.arn}" \
        --name "$EXEC_NAME" \
        --input "$INPUT" \
        --query executionArn --output text)

      echo "Polling execution: $EXEC_ARN"
      DEADLINE=$(( $(date +%s) + ${var.timeout_seconds} ))
      while :; do
        if [ "$(date +%s)" -gt "$DEADLINE" ]; then
          echo "Polling timed out after ${var.timeout_seconds}s; SFN execution still running in AWS." >&2
          exit 1
        fi
        STATUS=$(aws stepfunctions describe-execution \
          --region "${data.aws_region.current.region}" \
          --execution-arn "$EXEC_ARN" \
          --query status --output text)
        case "$STATUS" in
          SUCCEEDED)
            echo "Task succeeded."
            exit 0
            ;;
          FAILED|TIMED_OUT|ABORTED)
            echo "Task $STATUS" >&2
            aws stepfunctions describe-execution \
              --region "${data.aws_region.current.region}" \
              --execution-arn "$EXEC_ARN" \
              --query '{error:error,cause:cause}' >&2
            exit 1
            ;;
          RUNNING)
            sleep ${var.poll_interval_seconds}
            ;;
          *)
            echo "Unexpected status: $STATUS" >&2
            sleep ${var.poll_interval_seconds}
            ;;
        esac
      done
    EOT
  }
}
