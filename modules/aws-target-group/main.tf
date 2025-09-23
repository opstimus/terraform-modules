resource "aws_lb_target_group" "main" {
  port        = var.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-${var.service}"
    },
    var.tags
  )

  health_check {
    matcher = var.application_status_code
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "main" {
  for_each     = var.listener_rules
  listener_arn = var.listener_arn
  priority     = each.value.priority
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-${var.service}"
    },
    var.tags
  )

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    host_header {
      values = each.value.host_headers
    }
  }

  dynamic "condition" {
    for_each = length(each.value.path_patterns) > 0 ? [1] : []
    content {
      path_pattern {
        values = each.value.path_patterns
      }
    }
  }
}
