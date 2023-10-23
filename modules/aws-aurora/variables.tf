variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "parameter_group_family" {
  type = string
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "engine_mode" {
  type        = string
  description = "multimaster, parallelquery, provisioned, serverless"
  default     = "provisioned"
}

variable "engine" {
  type        = string
  description = "aurora-mysql, aurora-postgresql"
}

variable "engine_version" {
  type        = string
  description = "i.e 8.0.mysql_aurora.3.03.0"
}

variable "db_name" {
  type        = string
  description = "Default database name"
}

variable "master_username" {
  type        = string
  description = "Master username"
  default     = "admin"
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "snapshot_identifier" {
  type    = string
  default = ""
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "log exports i.e: audit, error, general, slowquery"
}

variable "backup_retention_period" {
  type        = number
  description = "Backup stored period"
  default     = 30
}

variable "storage_encrypted" {
  type    = bool
  default = false
}

variable "kms_key_id" {
  type        = string
  description = "KMS key id to use when storage encryption is true"
}

variable "network_type" {
  type        = string
  description = "IPV4, DUAL"
  default     = "IPV4"
}

variable "performance_insights_enabled" {
  type    = bool
  default = false
}

variable "instancetype" {
  type        = string
  description = "Instance type (micro, medium or large)"
  default     = "db.t3.medium"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "vpc_cidr" {
  type = string
}

variable "parameter_group_parameters" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
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
