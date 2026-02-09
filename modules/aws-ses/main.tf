resource "aws_ses_domain_identity" "main" {
  count  = var.identity_type == "domain" ? 1 : 0
  domain = var.ses_domain
}

resource "aws_ses_email_identity" "main" {
  count = var.identity_type == "email" ? 1 : 0
  email = var.ses_email
}

resource "aws_ses_domain_identity_verification" "main" {
  domain = aws_ses_domain_identity.main.id
}
