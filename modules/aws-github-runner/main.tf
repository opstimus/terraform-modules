locals {
  resource_name         = "${var.project}-${var.environment}-${var.name}-github-runner"
  github_connection_arn = var.create_github_connection ? aws_codestarconnections_connection.github[0].arn : var.github_connection_arn
}

# IAM role for CodeBuild runner
resource "aws_iam_role" "github_runner" {
  name = local.resource_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "github_runner_logs" {
  name = "${local.resource_name}-logs"
  role = aws_iam_role.github_runner.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${var.deploy_region}:*:log-group:/aws/codebuild/${local.resource_name}",
          "arn:aws:logs:${var.deploy_region}:*:log-group:/aws/codebuild/${local.resource_name}:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "github_runner_vpc" {
  name = "${local.resource_name}-vpc"
  role = aws_iam_role.github_runner.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["ec2:CreateNetworkInterfacePermission"]
        Resource = "arn:aws:ec2:${var.deploy_region}:*:network-interface/*"
        Condition = {
          StringEquals = {
            "ec2:AuthorizedService" = "codebuild.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "github_runner_connections" {
  name = "${local.resource_name}-connections"
  role = aws_iam_role.github_runner.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection",
          "codeconnections:UseConnection",
          "codeconnections:GetConnectionToken",
          "codeconnections:GetConnection"
        ]
        Resource = local.github_connection_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_runner_additional" {
  for_each   = toset(var.additional_policy_arns)
  role       = aws_iam_role.github_runner.name
  policy_arn = each.value
}

resource "aws_security_group" "github_runner" {
  name        = local.resource_name
  description = local.resource_name
  vpc_id      = var.vpc_id

  tags = {
    Name = local.resource_name
  }
}

# All traffic enabled for outbound (required for GitHub Actions)
resource "aws_vpc_security_group_egress_rule" "ipv4" {
  security_group_id = aws_security_group.github_runner.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "ipv6" {
  security_group_id = aws_security_group.github_runner.id

  ip_protocol = "-1"
  cidr_ipv6   = "::/0"
}

# GitHub App connection via AWS CodeConnections (one-time manual activation required after apply)
resource "aws_codestarconnections_connection" "github" {
  count         = var.create_github_connection ? 1 : 0
  name          = local.resource_name
  provider_type = "GitHub"
}

# Registers the CodeConnections GitHub App as the credential for CodeBuild GitHub operations
resource "aws_codebuild_source_credential" "github" {
  auth_type   = "CODECONNECTIONS"
  server_type = "GITHUB"
  token       = local.github_connection_arn
}

resource "aws_codebuild_project" "github_runner" {
  name          = local.resource_name
  description   = "GitHub Actions runner for ${var.github_repository}"
  service_role  = aws_iam_role.github_runner.arn
  build_timeout = var.build_timeout

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = var.compute_type
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/${var.github_repository}"
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = false
    }

    auth {
      type     = "CODECONNECTIONS"
      resource = local.github_connection_arn
    }
  }

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.subnet_ids
    security_group_ids = [aws_security_group.github_runner.id]
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${local.resource_name}"
      stream_name = "build-log"
    }
  }

  tags = {
    Name = local.resource_name
  }

  depends_on = [
    aws_iam_role_policy.github_runner_connections,
    aws_codebuild_source_credential.github,
  ]
}

resource "aws_codebuild_webhook" "github_runner" {
  project_name = aws_codebuild_project.github_runner.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "WORKFLOW_JOB_QUEUED"
    }
  }
}
