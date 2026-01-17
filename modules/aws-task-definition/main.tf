resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project}-${var.environment}-${var.service}"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = length(var.task_role_policy) != 0 ? aws_iam_role.main[0].arn : null
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions    = var.container_definitions

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_iam_role" "main" {
  count = length(var.task_role_policy) != 0 ? 1 : 0
  name  = "${var.project}-${var.environment}-${var.service}-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "main" {
  count = length(var.task_role_policy) != 0 ? 1 : 0
  name  = "${var.project}-${var.environment}-${var.service}-task"
  role  = aws_iam_role.main[0].id

  policy = var.task_role_policy
}
