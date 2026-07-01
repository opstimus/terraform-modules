resource "aws_appautoscaling_scheduled_action" "main" {
  name               = "${var.service_name}-${var.policy_name}"
  resource_id        = var.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  schedule           = var.schedule

  scalable_target_action {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }
}
