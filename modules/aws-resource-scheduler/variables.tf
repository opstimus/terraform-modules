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
  default     = "resource-scheduler"
  description = "Function/role name suffix"
}

variable "nat_instance_ids" {
  type        = list(string)
  default     = []
  description = "EC2 instance IDs (i-...) or Name tags of NAT instances to start/stop"
}

variable "rds_cluster_ids" {
  type        = list(string)
  default     = []
  description = "Aurora/RDS cluster identifiers to start/stop"
}

variable "rds_instance_ids" {
  type        = list(string)
  default     = []
  description = "Standalone RDS instance identifiers to start/stop"
}

variable "ecs_services" {
  type = list(object({
    cluster       = string
    service       = string
    desired_count = number
  }))
  default     = []
  description = "ECS services to scale, and the desired count to restore on 'up'"
}

variable "timeout" {
  type        = number
  default     = 870
  description = "Lambda timeout in seconds, budgeted for sequential start/stop waiters (hard cap 900)"
}

variable "memory_size" {
  type        = number
  default     = 128
  description = "Memory allocated to the Lambda function (in MB)"
}

variable "log_retention_days" {
  type        = number
  default     = 30
  description = "CloudWatch log retention for the Lambda's log group"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to the Lambda function"
}
