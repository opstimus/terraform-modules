resource "aws_sns_topic" "main" {
  name         = var.sns_type == "fifo" ? "${var.project}-${var.environment}-${var.name}.fifo" : "${var.project}-${var.environment}-${var.name}"
  display_name = var.sns_type == "fifo" ? "${var.project}-${var.environment}-${var.name}.fifo" : "${var.project}-${var.environment}-${var.name}"
  fifo_topic   = var.sns_type == "fifo" ? true : false
}
