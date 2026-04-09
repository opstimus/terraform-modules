variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "resource_name" {
  type        = string
  description = "Resource name created KMS for"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}

variable "enable_key_rotation" {
  type    = bool
  default = true
}

variable "key_policy_statements" {
  type = list(object({
    sid    = optional(string, "")
    effect = string
    principals = list(object({
      type        = string
      identifiers = list(string)
    }))
    actions   = list(string)
    resources = list(string)
  }))
  default     = []
  description = "Additional key policy statements merged with the default root account statement. Use for service principals (e.g. dsql.amazonaws.com) or cross-account access."
}
