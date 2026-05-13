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
  description = "Resource name suffix | e.g. migrate"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resources."
  default     = {}
}

variable "cluster_arn" {
  type        = string
  description = "ARN of the ECS cluster the task will run in."
}

variable "task_definition_arn" {
  type        = string
  description = "ARN of the ECS task definition to run, including revision (e.g. arn:aws:ecs:...:task-definition/foo:42). The revision is used to derive a deterministic Step Function execution name."
}

variable "task_execution_role_arn" {
  type        = string
  description = "ARN of the ECS task execution role (used by ECS to pull the image, fetch secrets, write logs)."
}

variable "task_role_arn" {
  type        = string
  description = "ARN of the task IAM role passed to the running container. When null, the module creates a default role with SSM exec-channel permissions."
  default     = null
}

variable "subnets" {
  type        = list(string)
  description = "Subnets the Fargate task will run in."
}

variable "security_groups" {
  type        = list(string)
  description = "Security groups attached to the Fargate task."
}

variable "assign_public_ip" {
  type        = bool
  description = "Whether the Fargate task receives a public IP."
  default     = false
}

variable "timeout_seconds" {
  type        = number
  description = "Maximum duration (in seconds) of the Step Function execution and the local-exec poll. Both are bounded by this value."
  default     = 1800
}

variable "poll_interval_seconds" {
  type        = number
  description = "Seconds between describe-execution polls in the local-exec wait loop."
  default     = 10
}

variable "execution_input" {
  type        = string
  description = "JSON string passed as input to the Step Function execution. Used as a label in the SFN console and as part of the idempotency key (same name + same input dedups in Standard workflows). Default \"{}\"."
  default     = "{}"
}
