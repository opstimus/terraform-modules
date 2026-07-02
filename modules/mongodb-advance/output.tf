output "connection_strings" {
  value = replace(mongodbatlas_advanced_cluster.main.connection_strings.standard_srv, "mongodb+srv://", "")
}

resource "aws_ssm_parameter" "dns" {
  name  = "/${var.project}/${var.environment}/central/mongo/${var.name}/dns"
  type  = "String"
  value = replace(mongodbatlas_advanced_cluster.main.connection_strings.standard_srv, "mongodb+srv://", "")
}

resource "aws_ssm_parameter" "username" {
  name  = "/${var.project}/${var.environment}/central/mongo/${var.name}/username"
  type  = "String"
  value = mongodbatlas_database_user.main.username
}
