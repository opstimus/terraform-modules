resource "aws_secretsmanager_secret" "main" {
  name = "${var.project}-${var.environment}-${var.name}"
  tags = var.tags
}

resource "random_password" "main" {
  count            = var.secret_string == "random" ? 1 : 0
  length           = var.random_length
  special          = var.random_special
  override_special = var.random_override_special
}

resource "aws_secretsmanager_secret_version" "example" {
  count         = var.secret_string != null ? 1 : 0
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = var.secret_string == "random" ? random_password.main[0].result : var.secret_string
}
