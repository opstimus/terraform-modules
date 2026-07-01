locals {
  name_prefix = var.name != "" ? "${var.project}-${var.environment}-${var.name}" : "${var.project}-${var.environment}"
}

resource "aws_iam_role" "task_execution" {
  name = "${local.name_prefix}-ecs-task-exec"

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

resource "aws_iam_role_policy_attachment" "task_execution_aws_managed" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "task_execution_custom" {
  role       = aws_iam_role.task_execution.name
  policy_arn = aws_iam_policy.main.arn
}

resource "aws_iam_policy" "main" {
  name        = "${local.name_prefix}-ecs-task-exec"
  description = "${local.name_prefix}-ecs-task-exec"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetRandomPassword",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "secretsmanager:ListSecretVersionIds"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_ecs_cluster" "main" {
  name = local.name_prefix

  setting {
    name  = "containerInsights"
    value = var.container_insights == true ? "enabled" : "disabled"
  }
  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}

resource "aws_security_group" "main" {
  name        = "${local.name_prefix}-ecs-cluster"
  description = "${local.name_prefix}-ecs-cluster"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name = "${local.name_prefix}-ecs-cluster"
    },
    var.tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "ingress_vpc" {
  security_group_id = aws_security_group.main.id
  ip_protocol       = "tcp"
  from_port         = 0
  to_port           = 65535
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_security_group_egress_rule" "ipv4" {
  security_group_id = aws_security_group.main.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "ipv6" {
  security_group_id = aws_security_group.main.id
  ip_protocol       = "-1"
  cidr_ipv6         = "::/0"
}
