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
  description = "Role name"
}

variable "assume_role_policy" {
  type = string
}

variable "role_policy" {
  type = string
}

variable "create_instance_profile" {
  type        = bool
  description = "Create IAM instance profile for the role"
  default     = false
}
