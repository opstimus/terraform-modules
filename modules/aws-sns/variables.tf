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
  description = "Topic name"
}

variable "sns_type" {
  type        = string
  description = "fifo / standard"
  default     = "standard"
}
