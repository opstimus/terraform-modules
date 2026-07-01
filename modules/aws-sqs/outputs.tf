output "sqs_arn" {
  value = aws_sqs_queue.main.arn
}

output "sqs_url" {
  value = aws_sqs_queue.main.url
}

output "dlq_sqs_arn" {
  value = var.enable_dlq == true ? aws_sqs_queue.dlq[0].arn : null
}

output "dlq_sqs_url" {
  value = var.enable_dlq == true ? aws_sqs_queue.dlq[0].url : null
}

resource "aws_ssm_parameter" "sqs_arn" {
  name  = "/${var.project}/${var.environment}/${var.name}/central/sqs/sqs_arn"
  type  = "String"
  value = aws_sqs_queue.main.arn
}

resource "aws_ssm_parameter" "sqs_url" {
  name  = "/${var.project}/${var.environment}/${var.name}/central/sqs/sqs_url"
  type  = "String"
  value = aws_sqs_queue.main.url
}

resource "aws_ssm_parameter" "dlq_sqs_arn" {
  count = var.enable_dlq ? 1 : 0
  name  = "/${var.project}/${var.environment}/${var.name}/central/sqs/dlq_sqs_arn"
  type  = "String"
  value = aws_sqs_queue.dlq[0].arn
}

resource "aws_ssm_parameter" "dlq_sqs_url" {
  count = var.enable_dlq ? 1 : 0
  name  = "/${var.project}/${var.environment}/${var.name}/central/sqs/dlq_sqs_url"
  type  = "String"
  value = aws_sqs_queue.dlq[0].url
}
