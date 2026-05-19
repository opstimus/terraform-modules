output "task_definition_arn" {
  value = aws_ecs_task_definition.main.arn
}

output "task_role_arn" {
  value       = one(aws_iam_role.main[*].arn)
  description = "ARN of the task IAM role this module created, or null when task_role_policy was empty (no role created)."
}