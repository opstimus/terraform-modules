output "vault_id" {
  description = "The OCID of the KMS vault."
  value       = oci_kms_vault.main.id
}

output "management_endpoint" {
  description = "The management endpoint of the KMS vault."
  value       = oci_kms_vault.main.management_endpoint
}
