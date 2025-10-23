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
  description = "Service name"
}

variable "subnet_ids" {
  type        = list(string)
  description = "list of Subnet IDs where EFS mount targets will be created"
}

variable "kms_key_id" {
  type        = string
  description = "ARN value of KMS key"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}

