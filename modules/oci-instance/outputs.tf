output "instance_id" {
  description = "The OCID of the compute instance."
  value       = oci_core_instance.main.id
}

output "nsg_id" {
  description = "The ID of the Network Security Group associated with the instance."
  value       = oci_core_network_security_group.main.id
}

output "private_ip" {
  description = "The private IP address of the instance's primary VNIC."
  value       = oci_core_instance.main.private_ip
  sensitive   = true
}

output "public_ip" {
  description = "The public IP address of the instance's primary VNIC."
  value       = oci_core_instance.main.public_ip
  sensitive   = true
}
