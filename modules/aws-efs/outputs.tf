output "efs_arn" {
  value = aws_efs_file_system.main.arn
}

output "efs_dns_name" {
  value = aws_efs_file_system.main.dns_name
}

output "efs_id" {
  value = aws_efs_file_system.main.id
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

resource "aws_ssm_parameter" "efs_id" {
  name  = "/${var.project}/${var.environment}/central/efs/efsId"
  type  = "String"
  value = aws_efs_file_system.main.id
}
