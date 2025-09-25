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
  description = "User name"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}

variable "user_policy" {
  type = string
}

variable "generate_access_secret_key" {
  type        = bool
  description = "Whether to generate and store access and secret keys in AWS Secrets Manager"
  default     = false
}
