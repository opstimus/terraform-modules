resource "aws_dsql_cluster" "main" {
  kms_encryption_key          = var.kms_key_arn
  deletion_protection_enabled = var.deletion_protection_enabled

  tags = {
    Name = "${var.project}-${var.environment}-${var.name}"
  }
}
