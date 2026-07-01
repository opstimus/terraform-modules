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
  description = "Name identifier for the runner (e.g., 'base', 'app')"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the CodeBuild runner will be deployed"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for CodeBuild VPC configuration"
}

variable "deploy_region" {
  type        = string
  description = "AWS region for deployment"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository in format owner/repo"
}

variable "compute_type" {
  type        = string
  description = "CodeBuild compute type for the runner"
  default     = "BUILD_GENERAL1_SMALL"
}

variable "build_timeout" {
  type        = number
  description = "Build timeout in minutes"
  default     = 60
}

variable "additional_policy_arns" {
  type        = list(string)
  description = "List of additional IAM policy ARNs to attach to the runner role"
  default     = []
}

variable "create_github_connection" {
  type        = bool
  description = "Whether to create the CodeConnections GitHub App connection. Set false if one already exists in this account/region and pass its ARN via github_connection_arn."
  default     = true
}

variable "github_connection_arn" {
  type        = string
  description = "Existing CodeConnections connection ARN. Only used when create_github_connection = false."
  default     = ""
}
