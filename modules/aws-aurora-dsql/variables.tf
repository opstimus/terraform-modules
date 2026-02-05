variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "name" {
  type        = string
  description = "Resource name"
}

variable "deletion_protection_enabled" {
  type        = bool
  description = "Deletion protection enabled"
  default     = true
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN"
}
