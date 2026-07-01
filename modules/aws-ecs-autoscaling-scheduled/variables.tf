variable "service_name" {
  type = string
}

variable "policy_name" {
  type = string
}

variable "schedule" {
  type        = string
  description = "Example: cron(0 8 * * ? *)"
}

variable "min_capacity" {
  type = number
}

variable "max_capacity" {
  type = number
}

variable "resource_id" {
  type = string
}
