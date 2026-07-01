resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project}-${var.environment}-${var.name}"
  protocol_type = "HTTP"
  version       = var.api_version

  cors_configuration {
    allow_origins = var.cors_allow_origins
    allow_methods = var.cors_allow_methods
    allow_headers = var.cors_allow_headers
    max_age       = var.cors_max_age
  }

  body = var.body != null ? var.body : null
}

resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_deployment" "main" {
  api_id = aws_apigatewayv2_api.main.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_domain_name" "main" {
  count       = var.domain_name != null ? 1 : 0
  domain_name = var.domain_name

  domain_name_configuration {
    certificate_arn = var.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "main" {
  count       = var.domain_name != null ? 1 : 0
  api_id      = aws_apigatewayv2_api.main.id
  domain_name = aws_apigatewayv2_domain_name.main[0].id
  stage       = aws_apigatewayv2_stage.main.id
}
