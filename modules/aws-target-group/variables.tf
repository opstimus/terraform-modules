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

variable "priority" {
  type        = number
  description = "Listerner rule priority number"
  default     = 100
}

variable "host_headers" {
  type        = list(any)
  description = "Service URLs | i.e api.domain.com"
}
