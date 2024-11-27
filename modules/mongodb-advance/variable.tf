variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "name" {
  type = string
}

variable "atlast_org_id" {
  type = string
}

variable "atlas_api_public_key" {
  type = string
}

variable "atlas_api_private_key" {
  type = string
}

variable "provider_name" {
  type        = string
  description = "AWS, AZURE, GCP"
  default     = "AWS"
}

variable "region" {
  type        = string
  description = "Values should be in uppercase: AP_SOUTHEAST_1"
}

variable "cluster_type" {
  type        = string
  description = "REPLICASET | SHARDED | GEOSHARDED"
  default     = "REPLICASET"
}

variable "db_version" {
  type = string
}

variable "backup_enabled" {
  type    = bool
  default = false
}

variable "termination_protection_enabled" {
  type    = bool
  default = false
}

variable "instance_size" {
  type = string
}

variable "disk_size_gb" {
  type    = number
  default = 10
}

variable "db_username" {
  type    = string
  default = "admin"
}

variable "db_name" {
  type = string
}

variable "witelist_ip_addresses" {
  type = map(string)
}

