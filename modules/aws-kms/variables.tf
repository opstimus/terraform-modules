variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "resource_name" {
  type        = string
  description = "Resource name created KMS for"
}

variable "enable_key_rotation" {
  type    = bool
  default = true
}
