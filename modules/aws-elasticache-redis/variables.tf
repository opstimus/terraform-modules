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
  description = "Optional name segment appended to resource names. Leave empty to keep the original naming and avoid recreating existing resources."
  default     = ""
}

variable "transit_encryption_mode" {
  type        = string
  description = "Transit encryption mode, either \"preferred\" or \"required\". Only applies when transit encryption is enabled. \"preferred\" allows both encrypted and plaintext connections and requires Redis engine 7.0.5 or above."
  default     = "preferred"

  validation {
    condition     = contains(["preferred", "required"], var.transit_encryption_mode)
    error_message = "transit_encryption_mode must be either \"preferred\" or \"required\"."
  }
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
