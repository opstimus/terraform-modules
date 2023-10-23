resource "aws_lb_target_group" "main" {
  port        = var.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    matcher = var.application_status_code
  }

  tags = {
    "name" = "${var.project}-${var.environment}-${var.service}"
  }
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = var.listener_arn
  priority     = var.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    host_header {
      values = var.host_headers
    }
  }
}
