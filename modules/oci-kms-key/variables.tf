variable "project" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, prod)."
  type        = string
}

variable "name" {
  description = "The name of the resource."
  type        = string
}

variable "compartment_id" {
  description = "The OCID of the compartment."
  type        = string
}

variable "kms_vault_management_endpoint" {
  description = "The management endpoint for the KMS vault."
  type        = string
}

variable "key_algorithm" {
  description = "Encryption algorithm for the KMS key"
  type        = string
  default     = "AES"

  validation {
    condition     = contains(["AES", "RSA", "ECDSA"], var.key_algorithm)
    error_message = "Algorithm must be one of: AES, RSA, ECDSA."
  }
}

variable "key_length" {
  description = "Key length in bytes. AES: 16/24/32 | RSA: 256/384/512 | ECDSA: 32/48/66"
  type        = number
  default     = 32

  validation {
    condition     = contains([16, 24, 32, 48, 66, 256, 384, 512], var.key_length)
    error_message = "key_length must be 16/24/32 (AES), 256/384/512 (RSA), or 32/48/66 (ECDSA)."
  }
}

variable "key_curve_id" {
  description = "Curve ID for ECDSA keys (P256, P384, P521). Required when algorithm is ECDSA"
  type        = string
  default     = null

  validation {
    condition     = var.key_curve_id == null || contains(["P256", "P384", "P521"], var.key_curve_id)
    error_message = "curve_id must be one of: P256, P384, P521."
  }
}

variable "tags" {
  description = "Free-form tags to apply to the resource."
  type        = map(string)
  default     = null
}
