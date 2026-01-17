output "role_name" {
  value = aws_iam_role.main.name
}

output "role_arn" {
  value = aws_iam_role.main.arn
}

output "instance_profile_name" {
  value       = var.create_instance_profile ? aws_iam_instance_profile.main[0].name : null
  description = "The name of the IAM instance profile (if created)"
}

output "instance_profile_arn" {
  value       = var.create_instance_profile ? aws_iam_instance_profile.main[0].arn : null
  description = "The ARN of the IAM instance profile (if created)"
}
