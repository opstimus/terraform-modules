resource "aws_efs_file_system" "main" {
  creation_token = "${var.project}-${var.environment}-${var.name}"
  encrypted      = var.kms_key_id != null ? true : false
  kms_key_id     = var.kms_key_id
  tags           = var.tags
}

resource "aws_security_group" "main" {
  name        = "${var.project}-${var.environment}-${var.name}"
  description = "Allow efs traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # adjust based on your VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags
}

resource "aws_efs_mount_target" "main" {
  for_each        = toset(var.subnet_ids)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = each.value
  security_groups = [aws_security_group.main.id]
}
