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
  description = "Service name"
}

variable "subnet_ids" {
  type        = list(string)
  description = "list of Subnet IDs where EFS mount targets will be created"
}
