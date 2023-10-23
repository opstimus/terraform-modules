output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  value = aws_ecs_cluster.main.arn
}

output "security_group_id" {
  value = aws_security_group.main.id
}

output "task_execution_role_arn" {
  value = aws_iam_role.task_execution.arn
}

resource "aws_ssm_parameter" "cluster_name" {
  name  = "/${var.project}/${var.environment}/central/ecs/clusterName"
  type  = "String"
  value = aws_ecs_cluster.main.name
}

resource "aws_ssm_parameter" "cluster_arn" {
  name  = "/${var.project}/${var.environment}/central/ecs/clusterArn"
  type  = "String"
  value = aws_ecs_cluster.main.arn
}

resource "aws_ssm_parameter" "security_group_id" {
  name  = "/${var.project}/${var.environment}/central/ecs/securityGroupId"
  type  = "String"
  value = aws_security_group.main.id
}

resource "aws_ssm_parameter" "task_execution_role_arn" {
  name  = "/${var.project}/${var.environment}/central/ecs/taskExecutionRoleArn"
  type  = "String"
  value = aws_iam_role.task_execution.arn
}
