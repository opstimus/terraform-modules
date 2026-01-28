resource "aws_security_group" "main" {
  count       = length(var.ingress_rules) > 0 ? 1 : 0
  name        = "${var.project}-${var.environment}-${var.name}"
  description = "${var.project}-${var.environment}-${var.name}"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "main" {
  for_each          = var.ingress_rules
  security_group_id = aws_security_group.main[0].id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.ip_protocol
  cidr_ipv4         = each.value.cidr_ipv4[0]
  description       = try(each.value.description, null)
  tags              = var.tags
}

resource "aws_vpc_security_group_egress_rule" "ipv4" {
  count             = length(var.ingress_rules) > 0 ? 1 : 0
  security_group_id = aws_security_group.main[0].id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  tags              = var.tags
}

resource "aws_vpc_security_group_egress_rule" "ipv6" {
  count             = length(var.ingress_rules) > 0 ? 1 : 0
  security_group_id = aws_security_group.main[0].id
  ip_protocol       = "-1"
  cidr_ipv6         = "::/0"
  tags              = var.tags
}

resource "aws_instance" "main" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = length(var.ingress_rules) > 0 ? [aws_security_group.main[0].id] : var.security_group_ids
  source_dest_check           = var.source_dest_check
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name != null ? var.key_name : null
  disable_api_termination     = var.termination_protection ? true : false
  associate_public_ip_address = var.associate_public_ip_address
  iam_instance_profile        = var.iam_instance_profile != null ? var.iam_instance_profile : null
  tags                        = var.tags
  root_block_device {
    delete_on_termination = true
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
  }

  user_data_replace_on_change = true
  user_data                   = var.user_data

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}

resource "aws_eip" "main" {
  count = var.enable_eip ? 1 : 0
  tags  = var.tags
}

resource "aws_eip_association" "main" {
  count         = var.enable_eip ? 1 : 0
  instance_id   = aws_instance.main.id
  allocation_id = aws_eip.main[0].id
}
