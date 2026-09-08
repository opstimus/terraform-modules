resource "aws_sfn_state_machine" "main" {
  name       = "${var.project}-${var.environment}-${var.name}"
  role_arn   = var.role_arn
  type       = var.type
  definition = var.definition

  dynamic "logging_configuration" {
    for_each = var.logging_configuration == null ? [] : [var.logging_configuration]
    content {
      log_destination        = logging_configuration.value.log_destination
      include_execution_data = logging_configuration.value.include_execution_data
      level                  = logging_configuration.value.level
    }
  }

  dynamic "tracing_configuration" {
    for_each = var.tracing_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  tags = var.tags
}
