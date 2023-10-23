resource "aws_ssm_parameter" "endpoint" {
  name  = "/${var.project}/${var.environment}/central/redis/endpoint"
  type  = "String"
  value = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "auth_token_secret" {
  value = aws_secretsmanager_secret.main[*].name
}
