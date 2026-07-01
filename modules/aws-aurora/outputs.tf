output "db_password_secret" {
  value = aws_secretsmanager_secret.main.name
}

resource "aws_ssm_parameter" "dns" {
  name  = "/${var.project}/${var.environment}/central/aurora${local.ssm_name}/dns"
  type  = "String"
  value = aws_rds_cluster.main.endpoint
}

resource "aws_ssm_parameter" "reader_endpoint" {
  name  = "/${var.project}/${var.environment}/central/aurora${local.ssm_name}/reader_endpoint"
  type  = "String"
  value = aws_rds_cluster.main.reader_endpoint
}

resource "aws_ssm_parameter" "master_username" {
  name  = "/${var.project}/${var.environment}/central/aurora${local.ssm_name}/master_username"
  type  = "String"
  value = var.master_username
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/${var.project}/${var.environment}/central/aurora${local.ssm_name}/db_name"
  type  = "String"
  value = var.db_name
}

resource "aws_ssm_parameter" "rds_proxy_endpoint" {
  count = var.enable_rds_proxy ? 1 : 0
  name  = "/${var.project}/${var.environment}/central/aurora${local.ssm_name}/rds_proxy_endpoint"
  type  = "String"
  value = aws_db_proxy.main[0].endpoint
}

resource "aws_ssm_parameter" "rds_proxy_readonly_endpoint" {
  count = var.enable_rds_proxy ? 1 : 0
  name  = "/${var.project}/${var.environment}/central/aurora${local.ssm_name}/rds_proxy_readonly_endpoint"
  type  = "String"
  value = aws_db_proxy_endpoint.main[0].endpoint
}

resource "aws_secretsmanager_secret" "master_credentials" {
  name = "${var.project}/${var.environment}/base/aurora${local.ssm_name}/master_credentials"
}

resource "aws_secretsmanager_secret_version" "master_credentials" {
  secret_id = aws_secretsmanager_secret.master_credentials.id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.main.result
  })
}
