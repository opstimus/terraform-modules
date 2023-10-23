resource "aws_iam_user" "main" {
  name = "${var.project}-${var.environment}-${var.name}"
}

resource "aws_iam_user_policy" "main" {
  name   = "${var.project}-${var.environment}-${var.name}"
  user   = aws_iam_user.main.name
  policy = var.user_policy
}

resource "aws_secretsmanager_secret" "access_key" {
  name = "${var.project}-${var.environment}-iam-access-key"
}

resource "aws_secretsmanager_secret" "secret_key" {
  name = "${var.project}-${var.environment}-iam-secret-key"
}
