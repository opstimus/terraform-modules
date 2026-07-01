output "cluster_id" {
  description = "The ID of the Redis cluster."
  value       = oci_redis_redis_cluster.main.id
}

output "nsg_id" {
  description = "The IDs of the Network Security Groups associated with the Redis cluster."
  value       = oci_core_network_security_group.main.id
}

output "primary_fqdn" {
  description = "The primary FQDN of the Redis cluster."
  value       = oci_redis_redis_cluster.main.primary_fqdn
  sensitive   = true
}

output "primary_endpoint_ip_address" {
  description = "The primary endpoint IP address of the Redis cluster."
  value       = oci_redis_redis_cluster.main.primary_endpoint_ip_address
  sensitive   = true
}

output "software_version" {
  description = "The software version of the Redis cluster."
  value       = oci_redis_redis_cluster.main.software_version
}
