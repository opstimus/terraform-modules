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
  description = "Bucket name as suffix project and environment"
}

variable "enable_versioning" {
  type    = bool
  default = true
}
