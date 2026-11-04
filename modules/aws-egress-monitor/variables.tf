variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs to check. One probe runs in each, so every AZ's egress path is checked separately."
}

variable "alarm_sns_arn" {
  type        = string
  description = "SNS topic arn"
}

variable "probe_url" {
  type        = string
  description = "URL each probe fetches to confirm outbound internet access"
  default     = "https://checkip.amazonaws.com"
}

variable "schedule_expression" {
  type        = string
  description = "How often the probes run. The alarm periods assume 5 minutes."
  default     = "rate(5 minutes)"
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch log retention for the probe functions"
  default     = 14
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}
