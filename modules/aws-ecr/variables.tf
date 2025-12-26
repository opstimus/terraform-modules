variable "project" {
  type        = string
  description = "Project name"
}

variable "service" {
  type        = string
  description = "Name of the service, i.e backend"
}

variable "image_tag_mutability" {
  type = bool
}

variable "scan_on_push" {
  type    = bool
  default = false
}

variable "account_ids" {
  type        = list(any)
  description = "Accounts that can pull images from the repository"
}

variable "create_iam_user" {
  type    = bool
  default = false
}

variable "create_iam_role" {
  type        = bool
  default     = false
  description = "Whether to create an IAM role for GitHub Actions OIDC"
}

variable "github_oidc_subjects" {
  type        = list(string)
  default     = []
  description = "List of GitHub OIDC subjects (e.g., 'repo:owner/repo:ref:refs/heads/main')"
}
