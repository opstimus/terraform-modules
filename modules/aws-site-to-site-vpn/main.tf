resource "aws_customer_gateway" "main" {
  bgp_asn     = 65000
  ip_address  = var.customer_gateway_ip_address
  type        = "ipsec.1"
  device_name = var.device_name

  tags = {
    Name = "${var.project}-${var.environment}-${var.name}"
  }
}

resource "aws_vpn_gateway" "main" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project}-${var.environment}-${var.name}"
  }
}

resource "aws_cloudwatch_log_group" "tunnel1" {
  name              = "/${var.project}/${var.environment}/tunnel1"
  retention_in_days = 120
}

resource "aws_cloudwatch_log_group" "tunnel2" {
  name              = "/${var.project}/${var.environment}/tunnel2"
  retention_in_days = 120
}

resource "aws_vpn_connection" "main" {
  vpn_gateway_id                       = aws_vpn_gateway.main[0].id
  customer_gateway_id                  = aws_customer_gateway.main[0].id
  type                                 = "ipsec.1"
  static_routes_only                   = true
  local_ipv4_network_cidr              = var.local_ipv4_network_cidr
  tunnel1_ike_versions                 = ["ikev2"]
  tunnel2_ike_versions                 = ["ikev2"]
  tunnel1_phase1_encryption_algorithms = ["AES256"]
  tunnel1_phase2_encryption_algorithms = ["AES256"]
  tunnel2_phase1_encryption_algorithms = ["AES256"]
  tunnel2_phase2_encryption_algorithms = ["AES256"]
  tunnel1_phase1_integrity_algorithms  = ["SHA2-256"]
  tunnel1_phase2_integrity_algorithms  = ["SHA2-256"]
  tunnel2_phase1_integrity_algorithms  = ["SHA2-256"]
  tunnel2_phase2_integrity_algorithms  = ["SHA2-256"]
  tunnel1_phase1_dh_group_numbers      = [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
  tunnel1_phase2_dh_group_numbers      = [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
  tunnel2_phase1_dh_group_numbers      = [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
  tunnel2_phase2_dh_group_numbers      = [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
  tunnel1_dpd_timeout_action           = "restart"
  tunnel2_dpd_timeout_action           = "restart"
  tunnel1_log_options {
    cloudwatch_log_options {
      log_enabled       = true
      log_group_arn     = aws_cloudwatch_log_group.tunnel1.arn
      log_output_format = "json"
    }
  }
  tunnel2_log_options {
    cloudwatch_log_options {
      log_enabled       = true
      log_group_arn     = aws_cloudwatch_log_group.tunnel2.arn
      log_output_format = "json"
    }
  }
  tags = {
    Name = "${var.project}-${var.environment}-${var.name}"
  }
}

resource "aws_vpn_connection_route" "main" {
  destination_cidr_block = var.local_ipv4_network_cidr
  vpn_connection_id      = aws_vpn_connection.main.id
}

resource "aws_route" "private_subnets" {
  for_each               = toset(var.route_table_ids)
  route_table_id         = each.value
  destination_cidr_block = var.local_ipv4_network_cidr
  gateway_id             = aws_vpn_gateway.main.id
}

