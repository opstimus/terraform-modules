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

variable "cluster_name" {
  type = string
}

variable "cluster_arn" {
  type = string
}

variable "task_definition" {
  type = string
}

variable "desired_count" {
  type = number
}

variable "target_group_arn" {
  type = string
}

variable "container_name" {
  type = string
}

variable "container_port" {
  type = number
}

variable "subnets" {
  type = list(string)
}

variable "security_group" {
  type = list(string)
}

variable "assign_public_ip" {
  type    = bool
  default = false
}

variable "alarm_sns_arn" {
  type        = string
  description = "SNS topic arn"
  default     = ""
}

variable "enable_cpu_alarm" {
  type        = bool
  description = "Enable CPU alarm"
  default     = false
}

variable "enable_memory_alarm" {
  type        = bool
  description = "Enable memory alarm"
  default     = false
}
