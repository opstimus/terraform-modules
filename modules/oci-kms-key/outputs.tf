output "kms_key_id" {
  description = "The OCID of the KMS key."
  value       = oci_kms_key.main.id
}

output "kms_vault_id" {
  description = "The OCID of the vault that owns this key (computed by the provider)."
  value       = oci_kms_key.main.vault_id
}
