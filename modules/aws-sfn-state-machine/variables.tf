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
  description = "State machine name"
}

variable "definition" {
  type        = string
  description = "Amazon States Language (ASL) JSON definition of the state machine"
}

variable "role_arn" {
  type        = string
  description = "ARN of the IAM role the state machine assumes at execution time"
}

variable "type" {
  type        = string
  description = "State machine type: STANDARD or EXPRESS"
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "EXPRESS"], var.type)
    error_message = "type must be one of: STANDARD, EXPRESS."
  }
}

variable "logging_configuration" {
  type = object({
    log_destination        = string
    include_execution_data = bool
    level                  = string
  })
  description = "CloudWatch Logs configuration. null (default) disables logging entirely."
  default     = null
}

variable "tracing_enabled" {
  type        = bool
  description = "Enable AWS X-Ray tracing"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}
