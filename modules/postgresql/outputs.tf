output "database_name" {
  description = "Name of the created database"
  value       = postgresql_database.database.name
}

output "database_user" {
  description = "Name of the created user/role"
  value       = postgresql_role.user.name
}

output "user_credentials_secret_name" {
  description = "Name of the Secrets Manager secret storing the created database user credentials"
  value       = aws_secretsmanager_secret.user_credentials.name
}

output "user_credentials_secret_arn" {
  description = "ARN of the Secrets Manager secret storing the created database user credentials"
  value       = aws_secretsmanager_secret.user_credentials.arn
}

