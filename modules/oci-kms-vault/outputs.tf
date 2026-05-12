output "vault_id" {
  description = "The OCID of the KMS vault."
  value       = oci_kms_vault.main.id
}

