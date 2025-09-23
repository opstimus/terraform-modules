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

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}

variable "enable_key_rotation" {
  type    = bool
  default = true
}
