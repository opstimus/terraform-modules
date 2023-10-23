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
  description = "Group name | i.e api"
}

variable "prefix" {
  type        = string
  description = "Service prefix | i.e ecs"
}

variable "retention_in_days" {
  type    = number
  default = 180
}
