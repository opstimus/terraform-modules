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

variable "port" {
  type        = string
  description = "Port number"
}

variable "target_type" {
  type        = string
  description = "Target type | i.e ip or instance"
  default     = "ip"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "application_status_code" {
  type        = number
  description = "Application health check status code"
  default     = 200
}

variable "listener_arn" {
  type        = string
  description = "Listerner ARN from ALB"
}

variable "listener_rules" {
  type = map(object({
    priority      = optional(number, 100)
    host_headers  = list(string)
    path_patterns = optional(list(string), [])
  }))
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}
