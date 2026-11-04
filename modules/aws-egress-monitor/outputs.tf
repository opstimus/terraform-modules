output "function_names" {
  value = aws_lambda_function.probe[*].function_name
}

output "alarm_names" {
  value = aws_cloudwatch_metric_alarm.egress[*].alarm_name
}
