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
  description = "Cluster name"
  default     = ""
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
  default     = "opadmin"
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
  default = true
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

variable "enable_rds_proxy" {
  type        = bool
  description = "Enable RDS Proxy"
  default     = false
}

variable "debug_logging" {
  type    = bool
  default = false
}

variable "engine_family" {
  type        = string
  description = "Engine Family i.e: MYSQL"
  default     = null
}

variable "require_tls" {
  type    = bool
  default = false
}

variable "port" {
  type        = number
  description = "SQL Port"
  default     = 0
}

variable "connection_borrow_timeout" {
  type    = number
  default = 120
}

variable "init_query" {
  type        = string
  description = "SQL statements to set up the initial session state for each connection"
  default     = null
}

variable "max_connections_percent" {
  type    = number
  default = 80
}

variable "max_idle_connections_percent" {
  type    = number
  default = 50
}

###############
# Autoscaling #
###############
variable "enable_autoscaling" {
  type    = bool
  default = false
}

variable "max_capacity" {
  type        = number
  description = "Auto Scaling maximum capacity"
  default     = 2
}

variable "cpu_target_value" {
  type        = number
  description = "CPU target value for autoscaling"
  default     = 80
}

variable "scale_out_cooldown" {
  type        = number
  description = "Cooldown period in seconds after a scale out activity"
  default     = 300
}

variable "scale_in_cooldown" {
  type        = number
  description = "Cooldown period in seconds after a scale in activity"
  default     = 900
}
