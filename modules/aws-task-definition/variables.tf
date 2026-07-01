variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "service" {
  type        = string
  description = "Service name | i.e api"
}

variable "execution_role_arn" {
  type        = string
  description = "ARN of execution role"
}

variable "cpu" {
  type        = number
  description = "CPU size | i.e 256"
  default     = "256"
}

variable "memory" {
  type        = number
  description = "Memory size | i.e 512"
  default     = "512"
}

variable "container_definitions" {
  type = string
}

variable "task_role_policy" {
  type    = string
  default = ""
}
