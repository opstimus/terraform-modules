output "efs_arn" {
  value = aws_efs_file_system.main.arn
}

output "efs_dns_name" {
  value = aws_efs_file_system.main.dns_name
}

output "efs_name" {
  value = aws_efs_file_system.main.name
}

resource "aws_ssm_parameter" "efs_arn" {
  name  = "/${var.project}/${var.environment}/central/efs/arn"
  type  = "String"
  value = aws_efs_file_system.main.arn
}

resource "aws_ssm_parameter" "efs_dns_name" {
  name  = "/${var.project}/${var.environment}/central/efs/efsDnsName"
  type  = "String"
  value = aws_efs_file_system.main.dns_name
}

resource "aws_ssm_parameter" "efs_name" {
  name  = "/${var.project}/${var.environment}/central/efs/efsName"
  type  = "String"
  value = aws_efs_file_system.main.name
}
