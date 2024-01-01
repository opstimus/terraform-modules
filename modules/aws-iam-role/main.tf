resource "aws_iam_role" "main" {
  name               = "${var.project}-${var.environment}-${var.name}"
  assume_role_policy = var.assume_role_policy
}

resource "aws_iam_role_policy" "main" {
  name   = "${var.project}-${var.environment}-${var.name}"
  role   = aws_iam_role.main.id
  policy = var.role_policy
}
