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
