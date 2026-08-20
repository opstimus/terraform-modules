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
  description = "Secret name | i.e mail-password"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}

variable "secret_string" {
  type    = string
  default = null
}

variable "random_length" {
  type        = number
  description = "Length of the generated value when secret_string = \"random\"."
  default     = 16
}

variable "random_special" {
  type        = bool
  description = "Whether the generated value may include special characters when secret_string = \"random\"."
  default     = true
}

variable "random_override_special" {
  type        = string
  description = "Set of special characters allowed when random_special is true."
  default     = "!#$%&*?"
}

variable "recovery_window_in_days" {
  type        = number
  description = "Number of days AWS Secrets Manager waits before permanently deleting the secret. Set to 0 to force immediate deletion without recovery."
  default     = 7
}
