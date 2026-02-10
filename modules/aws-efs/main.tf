resource "aws_efs_file_system" "main" {
  creation_token = "${var.project}-${var.environment}-${var.name}"
  encrypted      = var.kms_key_id != null ? true : false
  kms_key_id     = var.kms_key_id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-${var.name}"
    },
    var.tags
  )
}

resource "aws_security_group" "main" {
  name        = "${var.project}-${var.environment}-${var.name}"
  description = "Allow efs traffic"
  vpc_id      = var.vpc_id

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "ingress_vpc" {
  security_group_id = aws_security_group.main.id

  ip_protocol = "tcp"
  from_port   = 2049
  to_port     = 2049
  cidr_ipv4   = var.vpc_cidr # adjust based on your VPC
}

resource "aws_vpc_security_group_egress_rule" "egress_ipv4" {
  security_group_id = aws_security_group.main.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "egress_ipv6" {
  security_group_id = aws_security_group.main.id

  ip_protocol = "-1"
  cidr_ipv6   = "::/0"
}

resource "aws_efs_mount_target" "main" {
  for_each        = toset(var.subnet_ids)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = each.value
  security_groups = [aws_security_group.main.id]
}
