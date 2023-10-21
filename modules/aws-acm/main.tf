resource "aws_acm_certificate" "main" {
  domain_name               = var.domain
  subject_alternative_names = var.wildcard == true ? ["*.${var.domain}"] : null
  validation_method         = "DNS"

  tags = {
    Environment = "${var.project}-${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn = aws_acm_certificate.main.arn
}
