variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "internal" {
  type        = bool
  description = "Create an internal facing loadbalancer"
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN"
}

variable "idle_timeout" {
  type        = number
  description = "In seconds upto 4000"
  default     = 60
}
