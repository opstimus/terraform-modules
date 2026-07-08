locals {

  # Broker ports to open based on the enabled encryption / authentication.
  #   9092 PLAINTEXT, 9094 TLS, 9096 SASL/SCRAM, 9098 SASL/IAM
  broker_ports = toset(compact([
    contains(["PLAINTEXT", "TLS_PLAINTEXT"], var.encryption_in_transit_client_broker) ? "9092" : "",
    contains(["TLS", "TLS_PLAINTEXT"], var.encryption_in_transit_client_broker) ? "9094" : "",
    var.enable_sasl_scram ? "9096" : "",
    var.enable_sasl_iam ? "9098" : "",
  ]))

  # Prometheus open-monitoring exporter ports, opened only when enabled.
  #   11001 JMX exporter, 11002 node exporter
  monitoring_ports = toset(compact([
    var.enable_open_monitoring && var.open_monitoring_jmx_exporter ? "11001" : "",
    var.enable_open_monitoring && var.open_monitoring_node_exporter ? "11002" : "",
  ]))

  enable_logging = var.log_group != "" || var.logs_s3_bucket != ""
}

resource "aws_security_group" "main" {
  name        = "${var.project}-${var.environment}-${var.name}-msk"
  description = "${var.project}-${var.environment}-${var.name}-msk"
  vpc_id      = var.vpc_id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-${var.name}-msk"
    },
    var.tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "broker" {
  for_each          = local.broker_ports
  security_group_id = aws_security_group.main.id
  ip_protocol       = "tcp"
  from_port         = tonumber(each.value)
  to_port           = tonumber(each.value)
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_security_group_ingress_rule" "monitoring" {
  for_each          = local.monitoring_ports
  security_group_id = aws_security_group.main.id
  ip_protocol       = "tcp"
  from_port         = tonumber(each.value)
  to_port           = tonumber(each.value)
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

resource "aws_msk_configuration" "main" {
  count             = var.configuration_server_properties != "" ? 1 : 0
  name              = "${var.project}-${var.environment}-${var.name}"
  kafka_versions    = [var.kafka_version]
  server_properties = var.configuration_server_properties

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_msk_cluster" "main" {
  cluster_name           = "${var.project}-${var.environment}-${var.name}"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes
  enhanced_monitoring    = var.enhanced_monitoring
  storage_mode           = var.storage_mode

  broker_node_group_info {
    instance_type   = var.instance_type
    client_subnets  = var.private_subnet_ids
    security_groups = [aws_security_group.main.id]

    storage_info {
      ebs_storage_info {
        volume_size = var.broker_volume_size

        dynamic "provisioned_throughput" {
          for_each = var.broker_provisioned_throughput > 0 ? [1] : []
          content {
            enabled           = true
            volume_throughput = var.broker_provisioned_throughput
          }
        }
      }
    }
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = var.kms_key_arn

    encryption_in_transit {
      client_broker = var.encryption_in_transit_client_broker
      in_cluster    = var.encryption_in_transit_in_cluster
    }
  }

  dynamic "client_authentication" {
    for_each = (var.enable_sasl_iam || var.enable_sasl_scram || var.enable_tls_auth || var.enable_unauthenticated) ? [1] : []
    content {
      dynamic "sasl" {
        for_each = (var.enable_sasl_iam || var.enable_sasl_scram) ? [1] : []
        content {
          iam   = var.enable_sasl_iam
          scram = var.enable_sasl_scram
        }
      }

      dynamic "tls" {
        for_each = var.enable_tls_auth ? [1] : []
        content {
          certificate_authority_arns = var.tls_certificate_authority_arns
        }
      }

      unauthenticated = var.enable_unauthenticated
    }
  }

  dynamic "configuration_info" {
    for_each = var.configuration_server_properties != "" ? [1] : []
    content {
      arn      = aws_msk_configuration.main[0].arn
      revision = aws_msk_configuration.main[0].latest_revision
    }
  }

  dynamic "logging_info" {
    for_each = local.enable_logging ? [1] : []
    content {
      broker_logs {
        dynamic "cloudwatch_logs" {
          for_each = var.log_group != "" ? [1] : []
          content {
            enabled   = true
            log_group = var.log_group
          }
        }

        dynamic "s3" {
          for_each = var.logs_s3_bucket != "" ? [1] : []
          content {
            enabled = true
            bucket  = var.logs_s3_bucket
            prefix  = var.logs_s3_prefix
          }
        }
      }
    }
  }

  dynamic "open_monitoring" {
    for_each = var.enable_open_monitoring ? [1] : []
    content {
      prometheus {
        jmx_exporter {
          enabled_in_broker = var.open_monitoring_jmx_exporter
        }
        node_exporter {
          enabled_in_broker = var.open_monitoring_node_exporter
        }
      }
    }
  }

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-${var.name}"
    },
    var.tags
  )

  lifecycle {
    # Force an explicit access decision instead of silently creating an
    # unauthenticated cluster when every enable_* flag is left at its default.
    precondition {
      condition     = var.enable_sasl_iam || var.enable_sasl_scram || var.enable_tls_auth || var.enable_unauthenticated
      error_message = "Enable at least one access method: set enable_sasl_iam, enable_sasl_scram or enable_tls_auth to true, or explicitly set enable_unauthenticated = true."
    }

    # SASL/IAM and SASL/SCRAM ride over TLS, so plaintext-only transit is invalid.
    precondition {
      condition     = (!var.enable_sasl_iam && !var.enable_sasl_scram) || contains(["TLS", "TLS_PLAINTEXT"], var.encryption_in_transit_client_broker)
      error_message = "SASL authentication (enable_sasl_iam / enable_sasl_scram) requires encryption_in_transit_client_broker to be TLS or TLS_PLAINTEXT."
    }

    # mTLS needs at least one ACM Private CA to validate client certificates.
    precondition {
      condition     = !var.enable_tls_auth || length(var.tls_certificate_authority_arns) > 0
      error_message = "enable_tls_auth requires at least one ACM Private CA ARN in tls_certificate_authority_arns."
    }

    # MSK places brokers evenly across AZs, so the node count must divide the subnets.
    precondition {
      condition     = length(var.private_subnet_ids) >= 2
      error_message = "private_subnet_ids must contain at least two subnets in different availability zones."
    }

    precondition {
      condition     = length(var.private_subnet_ids) > 0 ? var.number_of_broker_nodes % length(var.private_subnet_ids) == 0 : false
      error_message = "number_of_broker_nodes must be a multiple of the number of private_subnet_ids (an equal number of brokers per AZ)."
    }
  }
}

resource "aws_msk_scram_secret_association" "main" {
  count = var.enable_sasl_scram && length(var.scram_secret_association_arns) > 0 ? 1 : 0

  cluster_arn     = aws_msk_cluster.main.arn
  secret_arn_list = var.scram_secret_association_arns
}

resource "aws_appautoscaling_target" "storage" {
  count = var.enable_storage_autoscaling ? 1 : 0

  service_namespace  = "kafka"
  resource_id        = aws_msk_cluster.main.arn
  scalable_dimension = "kafka:broker-storage:VolumeSize"
  min_capacity       = var.broker_volume_size
  max_capacity       = var.broker_storage_max_size

  lifecycle {
    precondition {
      condition     = var.broker_storage_max_size >= var.broker_volume_size
      error_message = "broker_storage_max_size must be greater than or equal to broker_volume_size when enable_storage_autoscaling is true."
    }
  }
}

resource "aws_appautoscaling_policy" "storage" {
  count = var.enable_storage_autoscaling ? 1 : 0

  name               = "${var.project}-${var.environment}-${var.name}-storage-scaling"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.storage[0].service_namespace
  resource_id        = aws_appautoscaling_target.storage[0].resource_id
  scalable_dimension = aws_appautoscaling_target.storage[0].scalable_dimension

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "KafkaBrokerStorageUtilization"
    }
    target_value = var.broker_storage_target_utilization
  }
}
