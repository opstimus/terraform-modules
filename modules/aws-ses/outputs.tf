output "ses_arn" {
  value = var.identity_type == "domain" ? aws_ses_domain_identity.main[0].arn : aws_ses_email_identity.main[0].arn
}
