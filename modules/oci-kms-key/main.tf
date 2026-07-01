resource "oci_kms_key" "main" {
  compartment_id      = var.compartment_id
  display_name        = "${var.project}-${var.environment}-${var.name}"
  management_endpoint = var.kms_vault_management_endpoint
  freeform_tags       = var.tags
  key_shape {
    algorithm = var.key_algorithm
    length    = var.key_length
    curve_id  = var.key_algorithm == "ECDSA" ? var.key_curve_id : null
  }

  lifecycle {
    precondition {
      condition     = var.key_algorithm != "ECDSA" || var.key_curve_id != null
      error_message = "key_curve_id is required when key_algorithm is ECDSA."
    }
    precondition {
      condition = (
        (var.key_algorithm == "AES" && contains([16, 24, 32], var.key_length)) ||
        (var.key_algorithm == "RSA" && contains([256, 384, 512], var.key_length)) ||
        (var.key_algorithm == "ECDSA" && contains([32, 48, 66], var.key_length))
      )
      error_message = "key_length is invalid for the selected algorithm. AES: 16/24/32 | RSA: 256/384/512 | ECDSA: 32/48/66."
    }
  }
}
