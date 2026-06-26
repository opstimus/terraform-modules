locals {
  # First non-empty bootstrap broker string, in precedence order
  # (IAM > SCRAM > TLS > plaintext). coalesce skips empty strings, so the value
  # always tracks whichever access method the cluster actually exposes, and can
  # never be empty (a client_authentication method is required - see the
  # precondition in main.tf), which keeps the SSM String parameter valid.
  bootstrap_brokers = coalesce(
    aws_msk_cluster.main.bootstrap_brokers_sasl_iam,
    aws_msk_cluster.main.bootstrap_brokers_sasl_scram,
    aws_msk_cluster.main.bootstrap_brokers_tls,
    aws_msk_cluster.main.bootstrap_brokers,
  )
}

resource "aws_ssm_parameter" "bootstrap_brokers" {
  name  = "/${var.project}/${var.environment}/${var.name}/central/msk/bootstrap-brokers"
  type  = "String"
  value = local.bootstrap_brokers
  tags  = var.tags
}

output "cluster_arn" {
  description = "ARN of the MSK cluster."
  value       = aws_msk_cluster.main.arn
}

output "cluster_name" {
  description = "Name of the MSK cluster."
  value       = aws_msk_cluster.main.cluster_name
}

output "security_group_id" {
  description = "ID of the security group created for the brokers."
  value       = aws_security_group.main.id
}

output "bootstrap_brokers" {
  description = "Bootstrap broker connection string matching the enabled access method."
  value       = local.bootstrap_brokers
}

output "bootstrap_brokers_tls" {
  description = "TLS bootstrap broker connection string."
  value       = aws_msk_cluster.main.bootstrap_brokers_tls
}

output "bootstrap_brokers_sasl_iam" {
  description = "SASL/IAM bootstrap broker connection string."
  value       = aws_msk_cluster.main.bootstrap_brokers_sasl_iam
}

output "bootstrap_brokers_sasl_scram" {
  description = "SASL/SCRAM bootstrap broker connection string."
  value       = aws_msk_cluster.main.bootstrap_brokers_sasl_scram
}

output "zookeeper_connect_string" {
  description = "ZooKeeper connection string (empty for KRaft-based clusters)."
  value       = aws_msk_cluster.main.zookeeper_connect_string
}
