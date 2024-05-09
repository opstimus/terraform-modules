output "db_password_secret" {
  value = aws_secretsmanager_secret.main.name
}

resource "aws_ssm_parameter" "dns" {
  name  = "/${var.project}/${var.environment}/central/aurora/dns"
  type  = "String"
  value = aws_rds_cluster.main.endpoint
}

resource "aws_ssm_parameter" "reader_endpoint" {
  name  = "/${var.project}/${var.environment}/central/aurora/reader_endpoint"
  type  = "String"
  value = aws_rds_cluster.main.reader_endpoint
}

resource "aws_ssm_parameter" "master_username" {
  name  = "/${var.project}/${var.environment}/central/aurora/master_username"
  type  = "String"
  value = var.master_username
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/${var.project}/${var.environment}/central/aurora/db_name"
  type  = "String"
  value = var.db_name
}

resource "aws_ssm_parameter" "rds_proxy_endpoint" {
  count = var.enable_rds_proxy ? 1 : 0
  name  = "/${var.project}/${var.environment}/central/aurora/rds_proxy_endpoint"
  type  = "String"
  value = aws_db_proxy.main[0].endpoint
}

resource "aws_ssm_parameter" "rds_proxy_readonly_endpoint" {
  count = var.enable_rds_proxy ? 1 : 0
  name  = "/${var.project}/${var.environment}/central/aurora/rds_proxy_readonly_endpoint"
  type  = "String"
  value = aws_db_proxy_endpoint.main[0].endpoint
}
