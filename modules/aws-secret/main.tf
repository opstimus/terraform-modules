resource "aws_secretsmanager_secret" "main" {
  name = "${var.project}-${var.environment}-${var.name}"
}

resource "random_password" "main" {
  count            = var.secret_string == "random" ? 1 : 0
  length           = 16
  special          = true
  override_special = "!#$%&*?"
}

resource "aws_secretsmanager_secret_version" "example" {
  count         = var.secret_string != null ? 1 : 0
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = var.secret_string == "random" ? random_password.main[0].result : var.secret_string
}
