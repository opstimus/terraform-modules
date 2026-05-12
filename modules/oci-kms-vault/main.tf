resource "oci_kms_vault" "main" {
  compartment_id = var.compartment_id
  display_name   = "${var.project}-${var.environment}-${var.name}"
  vault_type     = "DEFAULT"
  freeform_tags  = var.tags
}
