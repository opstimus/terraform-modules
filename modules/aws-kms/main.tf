resource "aws_kms_key" "main" {
  description             = "${var.resource_name} custom kms key"
  deletion_window_in_days = 7
  enable_key_rotation     = var.enable_key_rotation
  tags = {
    "Name" = "${var.project}-${var.environment}-${var.resource_name}"
  }
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project}-${var.environment}-${var.resource_name}"
  target_key_id = aws_kms_key.main.key_id
}
