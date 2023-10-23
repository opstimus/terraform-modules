resource "aws_security_group" "main" {
  name        = "${var.project}-${var.environment}-redis"
  description = "${var.project}-${var.environment}-redis"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project}-${var.environment}-redis"
  }
}

resource "aws_elasticache_parameter_group" "main" {
  count  = length(var.parameter_group_parameters) != 0 ? 1 : 0
  name   = "${var.project}-${var.environment}"
  family = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameter_group_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project}-${var.environment}"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project}-${var.environment}"
  }
}

resource "random_password" "main" {
  count            = var.enable_auth ? 1 : 0
  length           = 16
  special          = true
  override_special = "!&#$^<>-"
}

resource "aws_secretsmanager_secret" "main" {
  count = var.enable_auth ? 1 : 0
  name  = "${var.project}-${var.environment}-redis"
}

resource "aws_secretsmanager_secret_version" "main" {
  count         = var.enable_auth ? 1 : 0
  secret_id     = aws_secretsmanager_secret.main[0].id
  secret_string = random_password.main[0].result
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = "${var.project}-${var.environment}"
  description                = "Primary replication group"
  apply_immediately          = true
  auto_minor_version_upgrade = false
  engine_version             = var.engine_version
  auth_token                 = length(random_password.main) > 0 ? random_password.main[0].result : null
  transit_encryption_enabled = var.enable_auth ? true : var.enable_transit_encryption
  at_rest_encryption_enabled = var.enable_at_rest_encryption
  node_type                  = var.node_type
  num_cache_clusters         = var.number_of_nodes
  parameter_group_name       = length(aws_elasticache_parameter_group.main) > 0 ? aws_elasticache_parameter_group.main[0].name : "default.${var.parameter_group_family}"
  port                       = 6379
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = [aws_security_group.main.id]

  log_delivery_configuration {
    destination      = var.log_group
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }
}
