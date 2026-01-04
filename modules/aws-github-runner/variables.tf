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
  description = "VPC ID where the runner will be deployed"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the runner instance"
}

variable "deploy_region" {
  type        = string
  description = "AWS region for deployment"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository in format owner/repo"
}

variable "name" {
  type        = string
  description = "Name identifier for the runner (e.g., 'base', 'app')"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.small"
}

variable "additional_policy_arns" {
  type        = list(string)
  description = "List of additional IAM policy ARNs to attach to the runner role"
  default     = []
}

