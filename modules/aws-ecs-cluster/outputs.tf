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

locals {
  ssm_base_path = var.name != "" ? "/${var.project}/${var.environment}/${var.name}" : "/${var.project}/${var.environment}/central"
}

resource "aws_ssm_parameter" "cluster_name" {
  name  = "${local.ssm_base_path}/ecs/clusterName"
  type  = "String"
  value = aws_ecs_cluster.main.name
}

resource "aws_ssm_parameter" "cluster_arn" {
  name  = "${local.ssm_base_path}/ecs/clusterArn"
  type  = "String"
  value = aws_ecs_cluster.main.arn
}

resource "aws_ssm_parameter" "security_group_id" {
  name  = "${local.ssm_base_path}/ecs/securityGroupId"
  type  = "String"
  value = aws_security_group.main.id
}

resource "aws_ssm_parameter" "task_execution_role_arn" {
  name  = "${local.ssm_base_path}/ecs/taskExecutionRoleArn"
  type  = "String"
  value = aws_iam_role.task_execution.arn
}
