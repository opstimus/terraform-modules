output "connection_strings" {
  value = mongodbatlas_advanced_cluster.main.connection_strings.0.standard_srv
}

resource "aws_ssm_parameter" "dns" {
  name  = "/${var.project}/${var.environment}/central/mongo/${var.name}/dns"
  type  = "String"
  value = mongodbatlas_advanced_cluster.main.connection_strings.0.standard_srv
}

resource "aws_ssm_parameter" "username" {
  name  = "/${var.project}/${var.environment}/central/mongo/${var.name}/username"
  type  = "String"
  value = mongodbatlas_database_user.main.username
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/${var.project}/${var.environment}/central/mongo/${var.name}/db_name"
  type  = "String"
  value = var.db_name
}
