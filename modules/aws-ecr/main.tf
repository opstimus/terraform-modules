resource "aws_ecr_repository" "main" {
  name                 = "${var.project}-${var.service}"
  image_tag_mutability = var.image_tag_mutability == true ? "IMMUTABLE" : "MUTABLE"

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}

locals {
  aws_accounts_arns = [for account_id in var.account_ids : "arn:aws:iam::${account_id}:root"]
}

data "aws_iam_policy_document" "main" {
  statement {
    sid    = "AccountsPull"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.aws_accounts_arns
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
  }

  statement {
    sid    = "AccountsPush"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.aws_accounts_arns
    }

    actions = [
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
  }
}

resource "aws_ecr_repository_policy" "main" {
  repository = aws_ecr_repository.main.name
  policy     = data.aws_iam_policy_document.main.json
}

resource "aws_iam_policy" "main" {
  name = "${var.project}-${var.service}-ecr-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Effect   = "Allow"
        Resource = aws_ecr_repository.main.arn
      },
      {
        Action = [
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Effect   = "Allow"
        Resource = aws_ecr_repository.main.arn
      }
    ]
  })
}

resource "aws_iam_user" "main" {
  count = var.create_iam_user ? 1 : 0
  name  = "${var.project}-${var.service}-ecr"
}

resource "aws_iam_user_policy_attachment" "main" {
  count      = var.create_iam_user ? 1 : 0
  user       = aws_iam_user.main[0].name
  policy_arn = aws_iam_policy.main.arn
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "role_trust" {
  count = var.create_iam_role ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.github_oidc_subjects
    }
  }
}

resource "aws_iam_role" "main" {
  count              = var.create_iam_role ? 1 : 0
  name               = "${var.project}-${var.service}-ecr"
  assume_role_policy = data.aws_iam_policy_document.role_trust[0].json
}

resource "aws_iam_role_policy_attachment" "main" {
  count      = var.create_iam_role ? 1 : 0
  role       = aws_iam_role.main[0].name
  policy_arn = aws_iam_policy.main.arn
}
