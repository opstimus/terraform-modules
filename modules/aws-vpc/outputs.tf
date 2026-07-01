output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "public_subnets" {
  value = join(",", [aws_subnet.public_1.id, aws_subnet.public_2.id, aws_subnet.public_3.id])
}

output "private_subnets" {
  value = join(",", [aws_subnet.private_1.id, aws_subnet.private_2.id, aws_subnet.private_3.id])
}

output "public_route_tables_id" {
  value = aws_default_route_table.public.id
}

output "private_route_tables_ids" {
  value = join(",", [aws_route_table.private_1.id, aws_route_table.private_2.id, aws_route_table.private_3.id])
}

resource "aws_ssm_parameter" "vpc_id" {
  name  = "/${var.project}/${var.environment}/central/vpc/id"
  type  = "String"
  value = aws_vpc.main.id
}

resource "aws_ssm_parameter" "vpc_cidr" {
  name  = "/${var.project}/${var.environment}/central/vpc/cidr"
  type  = "String"
  value = aws_vpc.main.cidr_block
}

resource "aws_ssm_parameter" "public_subnets_ids" {
  name  = "/${var.project}/${var.environment}/central/vpc/publicSubnetIds"
  type  = "StringList"
  value = join(",", [aws_subnet.public_1.id, aws_subnet.public_2.id, aws_subnet.public_3.id])
}

resource "aws_ssm_parameter" "private_subnets_ids" {
  name  = "/${var.project}/${var.environment}/central/vpc/privateSubnetIds"
  type  = "StringList"
  value = join(",", [aws_subnet.private_1.id, aws_subnet.private_2.id, aws_subnet.private_3.id])
}

resource "aws_ssm_parameter" "public_route_tables_ids" {
  name  = "/${var.project}/${var.environment}/central/vpc/publicRouteTableIds"
  type  = "StringList"
  value = aws_default_route_table.public.id
}

resource "aws_ssm_parameter" "private_route_tables_ids" {
  name  = "/${var.project}/${var.environment}/central/vpc/privateRouteTableIds"
  type  = "StringList"
  value = join(",", [aws_route_table.private_1.id, aws_route_table.private_2.id, aws_route_table.private_3.id])
}

output "isolated_subnets" {
  value = var.enable_isolated_subnets ? join(",", [aws_subnet.isolated_1[0].id, aws_subnet.isolated_2[0].id, aws_subnet.isolated_3[0].id]) : null
}

output "isolated_route_tables_ids" {
  value = var.enable_isolated_subnets ? join(",", [aws_route_table.isolated_1[0].id, aws_route_table.isolated_2[0].id, aws_route_table.isolated_3[0].id]) : null
}

resource "aws_ssm_parameter" "isolated_subnets_ids" {
  count = var.enable_isolated_subnets ? 1 : 0
  name  = "/${var.project}/${var.environment}/central/vpc/isolatedSubnetIds"
  type  = "StringList"
  value = join(",", [aws_subnet.isolated_1[0].id, aws_subnet.isolated_2[0].id, aws_subnet.isolated_3[0].id])
}

resource "aws_ssm_parameter" "isolated_route_tables_ids" {
  count = var.enable_isolated_subnets ? 1 : 0
  name  = "/${var.project}/${var.environment}/central/vpc/isolatedRouteTableIds"
  type  = "StringList"
  value = join(",", [aws_route_table.isolated_1[0].id, aws_route_table.isolated_2[0].id, aws_route_table.isolated_3[0].id])
}
