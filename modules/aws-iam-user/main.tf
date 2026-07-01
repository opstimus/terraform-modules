resource "aws_iam_user" "main" {
  name = "${var.project}-${var.environment}-${var.name}"
  tags = var.tags
}

resource "aws_iam_user_policy" "main" {
  name   = "${var.project}-${var.environment}-${var.name}"
  user   = aws_iam_user.main.name
  policy = var.user_policy
}

resource "aws_iam_access_key" "main" {
  count = var.generate_access_secret_key ? 1 : 0
  user  = aws_iam_user.main.name
}

resource "aws_secretsmanager_secret" "access_key" {
  count = var.generate_access_secret_key ? 1 : 0
  name  = "${var.project}-${var.environment}-${var.name}-iam-access-key"
  tags  = var.tags
}

resource "aws_secretsmanager_secret_version" "access_key" {
  count         = var.generate_access_secret_key ? 1 : 0
  secret_id     = aws_secretsmanager_secret.access_key[0].id
  secret_string = aws_iam_access_key.main[0].id
}

resource "aws_secretsmanager_secret" "secret_key" {
  count = var.generate_access_secret_key ? 1 : 0
  name  = "${var.project}-${var.environment}-${var.name}-iam-secret-key"
  tags  = var.tags
}

resource "aws_secretsmanager_secret_version" "secret_key" {
  count         = var.generate_access_secret_key ? 1 : 0
  secret_id     = aws_secretsmanager_secret.secret_key[0].id
  secret_string = aws_iam_access_key.main[0].secret
}
