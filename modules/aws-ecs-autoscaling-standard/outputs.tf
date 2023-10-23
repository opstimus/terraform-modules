output "resource_id" {
  value = aws_appautoscaling_target.main.resource_id
}

output "scalable_dimension" {
  value = aws_appautoscaling_target.main.scalable_dimension
}

output "service_namespace" {
  value = aws_appautoscaling_target.main.service_namespace
}
