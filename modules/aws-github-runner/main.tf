locals {
  resource_name            = "${var.project}-${var.environment}-${var.name}-github-runner"
  github_token_secret_name = "github/runner/token"
}

# IAM role for GitHub runner to access Secrets Manager
resource "aws_iam_role" "github_runner" {
  name = local.resource_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "github_runner_secrets" {
  name = "${local.resource_name}-secrets"
  role = aws_iam_role.github_runner.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:${var.deploy_region}:*:secret:${local.github_token_secret_name}*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_runner_additional" {
  for_each   = toset(var.additional_policy_arns)
  role       = aws_iam_role.github_runner.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "github_runner" {
  name = local.resource_name
  role = aws_iam_role.github_runner.name
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_security_group" "github_runner" {
  name        = local.resource_name
  description = local.resource_name
  vpc_id      = var.vpc_id

  # All traffic enabled for outbound (required for GitHub Actions)
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = local.resource_name
  }
}

resource "aws_instance" "github_runner" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.github_runner.id]
  iam_instance_profile        = aws_iam_instance_profile.github_runner.name
  associate_public_ip_address = false
  source_dest_check           = true

  root_block_device {
    delete_on_termination = true
    volume_size           = 10
    volume_type           = "gp3"
    encrypted             = true
  }

  user_data_replace_on_change = true
  user_data                   = <<-EOF
    #!/bin/bash
    set -e

    # Update system
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get upgrade -y

    # Install dependencies
    apt-get install -y curl jq unzip nodejs

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install

    # Get GitHub token from Secrets Manager using instance IAM role
    GITHUB_TOKEN=$(aws secretsmanager get-secret-value --secret-id "${local.github_token_secret_name}" --region "${var.deploy_region}" --query 'SecretString' --output text)

    if [ -z "$GITHUB_TOKEN" ]; then
      echo "ERROR: Failed to retrieve GitHub token from Secrets Manager"
      exit 1
    fi

    # Get registration token from GitHub API
    REGISTRATION_TOKEN=$(curl -L \
      -X POST \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer $GITHUB_TOKEN" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      https://api.github.com/repos/${var.github_repository}/actions/runners/registration-token | jq -r '.token')

    if [ -z "$REGISTRATION_TOKEN" ] || [ "$REGISTRATION_TOKEN" = "null" ]; then
      echo "ERROR: Failed to retrieve registration token from GitHub API"
      exit 1
    fi

    # Create actions-runner directory
    cd /opt
    mkdir actions-runner && cd actions-runner

    # Download the latest runner
    RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r '.tag_name')
    RUNNER_VERSION=$${RUNNER_VERSION#v}  # Remove 'v' prefix if present
    curl -o actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v$${RUNNER_VERSION}/actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz
    tar xzf ./actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz

    # Configure the runner
    export RUNNER_ALLOW_RUNASROOT="1"
    ./config.sh --url https://github.com/${var.github_repository} --token "$REGISTRATION_TOKEN" --name ${local.resource_name} --replace --unattended

    # Run the runner (not as a service since instance is temporary)
    ./run.sh
  EOF

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = local.resource_name
  }
}

