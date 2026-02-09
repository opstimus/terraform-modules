variable "ses_domain" {
  type        = string
  description = "Domain name (domain.com or subdomain.domain.com)"
}

variable "ses_email" {
  type        = string
  description = "Email address for SES email identity"
  default     = null
}

variable "identity_type" {
  type        = string
  description = "Type of SES identity to create (domain or email)"
  default     = null
}
