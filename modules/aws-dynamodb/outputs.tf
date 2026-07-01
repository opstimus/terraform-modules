output "dynamodb_table_arn" {
  value = aws_dynamodb_table.main.arn
}

output "dynamodb_stream_arn" {
  value = var.enable_stream ? aws_dynamodb_table.main.stream_arn : null
}
