variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "domain" {
  type        = string
  description = "domain.com"
}


variable "wildcard" {
  type        = bool
  description = "Create wildcard certificate"
}
