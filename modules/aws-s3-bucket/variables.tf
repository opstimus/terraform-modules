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
  description = "Bucket name as suffix project and environment"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}

variable "enable_versioning" {
  type    = bool
  default = true
}
