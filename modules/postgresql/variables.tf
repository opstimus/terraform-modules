variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "service_name" {
  type        = string
  description = "Service name"
}

variable "database_name" {
  type        = string
  description = "Name of the PostgreSQL database to create"
}

variable "database_user" {
  type        = string
  description = "Name of the PostgreSQL user/role to create"
}

variable "master_username" {
  type        = string
  description = "Master database username (used as owner for default privileges)"
}

