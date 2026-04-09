data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  bucket_name = var.bucket_namespace == "account-regional" ? format(
    "%s-%s-%s-%s-%s-an",
    var.project,
    var.environment,
    var.name,
    data.aws_caller_identity.current.account_id,
    data.aws_region.current.region
  ) : "${var.project}-${var.environment}-${var.name}"
}

resource "aws_s3_bucket" "main" {
  bucket           = local.bucket_name
  bucket_namespace = var.bucket_namespace
  tags             = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "main" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "main" {
  count  = var.bucket_policy != null ? 1 : 0
  bucket = aws_s3_bucket.main.id
  policy = var.bucket_policy

  depends_on = [aws_s3_bucket_public_access_block.main]
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}
