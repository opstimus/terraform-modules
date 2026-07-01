output "vpn_connection_id" {
  value = aws_vpn_connection.main.id
}

output "vpn_gateway_id" {
  value = aws_vpn_connection.main.vpn_gateway_id
}

output "customer_gateway_id" {
  value = aws_vpn_connection.main.customer_gateway_id
}
