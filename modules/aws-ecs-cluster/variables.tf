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

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "container_insights" {
  type    = bool
  default = false
}
