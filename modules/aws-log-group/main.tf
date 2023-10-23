resource "aws_cloudwatch_log_group" "main" {
  name              = "/${var.prefix}/${var.project}/${var.environment}/${var.name}"
  retention_in_days = var.retention_in_days
}
