variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}

variable "domain" {
  type        = string
  description = "domain.com"
}


variable "wildcard" {
  type        = bool
  description = "Create wildcard certificate"
}
