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
  description = "API name"
}

variable "cors_allow_origins" {
  type = list(string)
}

variable "cors_allow_methods" {
  type    = list(string)
  default = ["*"]
}

variable "cors_allow_headers" {
  type    = list(any)
  default = ["*"]
}

variable "cors_max_age" {
  type    = number
  default = 5
}

variable "api_version" {
  type    = string
  default = "1.0"
}

variable "body" {
  type    = string
  default = null
}

variable "domain_name" {
  type    = string
  default = null
}

variable "certificate_arn" {
  type    = string
  default = null
}
