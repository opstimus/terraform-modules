data "aws_region" "current" {}

locals {
  name     = var.name != "" ? "-${var.name}" : ""
  ssm_name = var.name != "" ? "/${var.name}" : ""
}

resource "aws_security_group" "db" {
  name        = "${var.project}-${var.environment}${local.name}-db"
  description = "${var.project}-${var.environment}${local.name}-db"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.port
    to_port     = var.port
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
    Name = "${var.project}-${var.environment}${local.name}-db"
  }
}

resource "random_password" "main" {
  length           = 16
  special          = true
  override_special = "!#$%&*?"
}

resource "aws_secretsmanager_secret" "main" {
  name = "${var.project}-${var.environment}${local.name}-db"
}
resource "aws_secretsmanager_secret_version" "main" {
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = random_password.main.result
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-${var.environment}${local.name}-aurora"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project}-${var.environment}${local.name}"
  }
}

resource "aws_db_parameter_group" "main" {
  count  = length(var.parameter_group_parameters) != 0 ? 1 : 0
  name   = "${var.project}-${var.environment}-${var.engine}"
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

resource "aws_rds_cluster_parameter_group" "main" {
  count  = length(var.parameter_group_parameters) != 0 ? 1 : 0
  name   = "${var.project}-${var.environment}-${var.engine}-cluster"
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

resource "time_static" "main" {}

resource "aws_rds_cluster" "main" {
  apply_immediately               = true
  engine_mode                     = var.engine_mode
  engine                          = var.engine
  engine_version                  = var.engine_version
  db_cluster_parameter_group_name = length(aws_rds_cluster_parameter_group.main) > 0 ? aws_rds_cluster_parameter_group.main[0].name : "default.${var.parameter_group_family}"
  db_subnet_group_name            = aws_db_subnet_group.main.name
  allow_major_version_upgrade     = false
  database_name                   = var.db_name
  master_username                 = var.master_username
  master_password                 = random_password.main.result
  skip_final_snapshot             = var.skip_final_snapshot
  final_snapshot_identifier       = "${var.project}-${var.environment}-${time_static.main.unix}"
  snapshot_identifier             = var.snapshot_identifier != "" ? var.snapshot_identifier : null
  deletion_protection             = var.deletion_protection
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  backup_retention_period         = var.backup_retention_period
  cluster_identifier              = "${var.project}-${var.environment}${local.name}-cluster"
  storage_encrypted               = var.storage_encrypted
  kms_key_id                      = var.storage_encrypted == true ? var.kms_key_id : null
  network_type                    = var.network_type
  vpc_security_group_ids          = [aws_security_group.db.id]
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                           = var.instance_count
  apply_immediately               = true
  identifier                      = "${var.project}-${var.environment}${local.name}-instance-${count.index}"
  cluster_identifier              = aws_rds_cluster.main.id
  engine                          = aws_rds_cluster.main.engine
  engine_version                  = aws_rds_cluster.main.engine_version
  instance_class                  = var.instancetype
  db_subnet_group_name            = aws_db_subnet_group.main.name
  db_parameter_group_name         = length(aws_rds_cluster_parameter_group.main) > 0 ? aws_rds_cluster_parameter_group.main[0].name : "default.${var.parameter_group_family}"
  auto_minor_version_upgrade      = false
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_enabled ? var.kms_key_id : null
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count                     = var.enable_cpu_alarm ? 1 : 0
  alarm_name                = "${var.project}-${var.environment}${local.name}: CPU usage on Aurora '${aws_rds_cluster.main.id}' is high"
  alarm_description         = "Aurora CPU utlization high"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 15
  datapoints_to_alarm       = 10
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/RDS"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 70
  insufficient_data_actions = []
  alarm_actions             = [var.alarm_sns_arn]
  ok_actions                = [var.alarm_sns_arn]
  dimensions = {
    DBInstanceIdentifier = aws_rds_cluster.main.id
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_critical" {
  count                     = var.enable_cpu_alarm ? 1 : 0
  alarm_name                = "${var.project}-${var.environment}${local.name}: CPU usage on Aurora '${aws_rds_cluster.main.id}' is critical"
  alarm_description         = "Aurora CPU utlization critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 15
  datapoints_to_alarm       = 10
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/RDS"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 90
  insufficient_data_actions = []
  alarm_actions             = [var.alarm_sns_arn]
  ok_actions                = [var.alarm_sns_arn]
  dimensions = {
    DBInstanceIdentifier = aws_rds_cluster.main.id
  }
}

resource "aws_secretsmanager_secret" "rds_proxy" {
  count = var.enable_rds_proxy ? 1 : 0
  name  = "${var.project}-${var.environment}${local.name}-db-rds-proxy"
}

resource "aws_secretsmanager_secret_version" "rds_proxy" {
  count     = var.enable_rds_proxy ? 1 : 0
  secret_id = aws_secretsmanager_secret.rds_proxy[0].id
  secret_string = jsonencode({
    username            = aws_rds_cluster.main.master_username
    password            = aws_rds_cluster.main.master_password
    engine              = var.engine_family
    host                = aws_rds_cluster.main.endpoint
    port                = var.port
    dbClusterIdentifier = aws_rds_cluster.main.cluster_identifier
  })
}

#############
# RDS Proxy #
#############
data "aws_kms_key" "rds_proxy" {
  key_id = "alias/aws/secretsmanager"
}

resource "aws_iam_role" "rds_proxy" {
  count = var.enable_rds_proxy ? 1 : 0
  name  = "${var.project}-${var.environment}${local.name}-db-rds-proxy"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "rds_proxy" {
  count = var.enable_rds_proxy ? 1 : 0
  name  = "${var.project}-${var.environment}${local.name}-db-rds-proxy"
  role  = aws_iam_role.rds_proxy[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "GetSecretValue",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Effect = "Allow"
        Resource = [
          aws_secretsmanager_secret.rds_proxy[0].arn
        ]
      },
      {
        Sid = "DecryptSecretValue",
        Action = [
          "kms:Decrypt"
        ],
        Effect = "Allow"
        Resource = [
          data.aws_kms_key.rds_proxy.arn
        ],
        Condition = {
          "StringEquals" = {
            "kms:ViaService" = "secretsmanager.${data.aws_region.current.name}.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_db_proxy" "main" {
  count                  = var.enable_rds_proxy ? 1 : 0
  name                   = "${var.project}-${var.environment}${local.name}-db"
  debug_logging          = var.debug_logging
  engine_family          = var.engine_family
  idle_client_timeout    = 1800
  require_tls            = var.require_tls
  role_arn               = aws_iam_role.rds_proxy[0].arn
  vpc_security_group_ids = [aws_security_group.db.id]
  vpc_subnet_ids         = var.private_subnet_ids

  auth {
    auth_scheme = "SECRETS"
    description = "Native Authentication"
    iam_auth    = "DISABLED"
    secret_arn  = aws_secretsmanager_secret.rds_proxy[0].arn
  }
}

resource "aws_db_proxy_default_target_group" "main" {
  count         = var.enable_rds_proxy ? 1 : 0
  db_proxy_name = aws_db_proxy.main[0].name

  connection_pool_config {
    connection_borrow_timeout    = var.connection_borrow_timeout
    init_query                   = var.init_query
    max_connections_percent      = var.max_connections_percent
    max_idle_connections_percent = var.max_idle_connections_percent
    session_pinning_filters      = ["EXCLUDE_VARIABLE_SETS"]
  }
}

resource "aws_db_proxy_target" "main" {
  count                 = var.enable_rds_proxy ? 1 : 0
  db_cluster_identifier = aws_rds_cluster.main.cluster_identifier
  db_proxy_name         = aws_db_proxy.main[0].name
  target_group_name     = aws_db_proxy_default_target_group.main[0].name
}

resource "aws_db_proxy_endpoint" "main" {
  count                  = var.enable_rds_proxy ? 1 : 0
  db_proxy_name          = aws_db_proxy.main[0].name
  db_proxy_endpoint_name = "${var.project}-${var.environment}${local.name}-readonly"
  vpc_subnet_ids         = var.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.db.id]
  target_role            = "READ_ONLY"
}

###############
# Autoscaling #
###############
resource "aws_appautoscaling_target" "main" {
  count = var.enable_autoscaling ? 1 : 0

  min_capacity       = var.instance_count - 1
  max_capacity       = var.max_capacity
  resource_id        = "cluster:${aws_rds_cluster.main.cluster_identifier}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"
}

resource "aws_appautoscaling_policy" "cpu" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "aurora-${aws_rds_cluster.main.cluster_identifier}-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.main[0].resource_id
  scalable_dimension = aws_appautoscaling_target.main[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.main[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "RDSReaderAverageCPUUtilization"
    }

    target_value       = var.cpu_target_value
    scale_out_cooldown = var.scale_out_cooldown
    scale_in_cooldown  = var.scale_in_cooldown
  }
}
