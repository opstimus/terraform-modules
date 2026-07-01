data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "main" {
  # Root account full access (KMS best practice; avoids lockout)
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = var.key_policy_statements
    content {
      sid    = statement.value.sid
      effect = statement.value.effect
      dynamic "principals" {
        for_each = statement.value.principals
        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}

resource "aws_kms_key" "main" {
  description             = "${var.resource_name} custom kms key"
  deletion_window_in_days = 7
  enable_key_rotation     = var.enable_key_rotation
  tags                    = var.tags
}

resource "aws_kms_key_policy" "main" {
  key_id = aws_kms_key.main.id
  policy = data.aws_iam_policy_document.main.json
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project}-${var.environment}-${var.resource_name}"
  target_key_id = aws_kms_key.main.key_id
}
