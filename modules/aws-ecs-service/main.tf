resource "aws_ecs_service" "main" {
  name                               = "${var.project}-${var.environment}-${var.service}"
  cluster                            = var.cluster_arn
  task_definition                    = var.task_definition
  desired_count                      = var.desired_count
  enable_execute_command             = true
  wait_for_steady_state              = true
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_group
    assign_public_ip = var.assign_public_ip
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = var.capacity_provider_fargate_spot_weight
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = var.capacity_provider_fargate_weight
    base              = var.capacity_provider_fargate_base
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count                     = var.enable_cpu_alarm ? 1 : 0
  alarm_name                = "${var.project}-${var.environment}: CPU usage in ECS service '${aws_ecs_service.main.name}' is high"
  alarm_description         = "ECS CPU utlization critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 4
  datapoints_to_alarm       = 3
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 70
  insufficient_data_actions = []
  treat_missing_data        = "ignore"
  alarm_actions             = [var.alarm_sns_arn]
  ok_actions                = [var.alarm_sns_arn]

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = aws_ecs_service.main.name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_critical" {
  count                     = var.enable_cpu_alarm ? 1 : 0
  alarm_name                = "${var.project}-${var.environment}: CPU usage in ECS service '${aws_ecs_service.main.name}' is critical"
  alarm_description         = "ECS CPU utlization critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 4
  datapoints_to_alarm       = 3
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 90
  insufficient_data_actions = []
  treat_missing_data        = "ignore"
  alarm_actions             = [var.alarm_sns_arn]
  ok_actions                = [var.alarm_sns_arn]

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = aws_ecs_service.main.name
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  count                     = var.enable_memory_alarm ? 1 : 0
  alarm_name                = "${var.project}-${var.environment}: Memory usage in ECS service '${aws_ecs_service.main.name}' is high"
  alarm_description         = "ECS memory utlization High"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 4
  datapoints_to_alarm       = 3
  metric_name               = "MemoryUtilization"
  namespace                 = "AWS/ECS"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 70
  insufficient_data_actions = []
  treat_missing_data        = "ignore"
  alarm_actions             = [var.alarm_sns_arn]
  ok_actions                = [var.alarm_sns_arn]

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = aws_ecs_service.main.name
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_critical" {
  count                     = var.enable_memory_alarm ? 1 : 0
  alarm_name                = "${var.project}-${var.environment}: Memory usage in ECS service '${aws_ecs_service.main.name}' is critical"
  alarm_description         = "ECS memory utlization High"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 4
  datapoints_to_alarm       = 3
  metric_name               = "MemoryUtilization"
  namespace                 = "AWS/ECS"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 90
  insufficient_data_actions = []
  treat_missing_data        = "ignore"
  alarm_actions             = [var.alarm_sns_arn]
  ok_actions                = [var.alarm_sns_arn]

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = aws_ecs_service.main.name
  }
}
