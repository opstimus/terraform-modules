locals {
  name_prefix = "${var.project}-${var.environment}-${var.name}"

  ec2_statements = length(var.nat_instance_ids) > 0 ? [{
    Sid      = "NatInstances"
    Effect   = "Allow"
    Action   = ["ec2:DescribeInstances", "ec2:StartInstances", "ec2:StopInstances"]
    Resource = "*"
  }] : []

  rds_statements = (length(var.rds_cluster_ids) > 0 || length(var.rds_instance_ids) > 0) ? [{
    Sid    = "Rds"
    Effect = "Allow"
    Action = [
      "rds:DescribeDBClusters", "rds:StartDBCluster", "rds:StopDBCluster",
      "rds:DescribeDBInstances", "rds:StartDBInstance", "rds:StopDBInstance",
    ]
    Resource = "*"
  }] : []

  ecs_statements = length(var.ecs_services) > 0 ? [{
    Sid      = "Ecs"
    Effect   = "Allow"
    Action   = ["ecs:DescribeServices", "ecs:UpdateService"]
    Resource = "*"
  }] : []

  policy_statements = concat(local.ec2_statements, local.rds_statements, local.ecs_statements)
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "/tmp/${local.name_prefix}.zip"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${local.name_prefix}"
  retention_in_days = var.log_retention_days
}

resource "aws_iam_role" "this" {
  name = local.name_prefix
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "this" {
  count = length(local.policy_statements) > 0 ? 1 : 0
  name  = local.name_prefix
  role  = aws_iam_role.this.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.policy_statements
  })
}

resource "aws_lambda_function" "this" {
  function_name    = local.name_prefix
  role             = aws_iam_role.this.arn
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.13"
  timeout          = var.timeout
  memory_size      = var.memory_size
  tags             = var.tags

  environment {
    variables = {
      NAT_INSTANCE_IDS = jsonencode(var.nat_instance_ids)
      RDS_CLUSTER_IDS  = jsonencode(var.rds_cluster_ids)
      RDS_INSTANCE_IDS = jsonencode(var.rds_instance_ids)
      ECS_SERVICES     = jsonencode(var.ecs_services)
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_iam_role_policy_attachment.basic_execution,
  ]
}
