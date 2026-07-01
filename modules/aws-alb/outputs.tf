resource "aws_ssm_parameter" "listerner" {
  name  = "/${var.project}/${var.environment}/${local.alb_name_suffix}/central/alb/httpsListener"
  type  = "String"
  value = aws_lb_listener.https.arn
}

output "dns_name" {
  value = aws_lb.main.dns_name
}

output "listener_arn" {
  value = aws_lb_listener.https.arn
}
