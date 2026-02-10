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

variable "parameter_group_family" {
  type = string
}

variable "parameter_group_parameters" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "node_type" {
  type = string
}

variable "number_of_nodes" {
  type    = number
  default = 1
}

variable "engine_version" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "log_group" {
  type = string
}

variable "enable_auth" {
  type    = bool
  default = false
}

variable "enable_transit_encryption" {
  type    = bool
  default = false
}

variable "enable_at_rest_encryption" {
  type    = bool
  default = false
}
