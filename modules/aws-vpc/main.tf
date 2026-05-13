data "aws_region" "current" {}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(
    {
      Name = "${var.project}-${var.environment}"
    },
    var.tags
  )
}

data "aws_availability_zones" "main" {
  state = "available"
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Public subnets
resource "aws_subnet" "public_1" {
  availability_zone       = data.aws_availability_zones.main.names[0]
  cidr_block              = var.public_cidr_1
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-public-1"
    },
    var.tags
  )
}

resource "aws_subnet" "public_2" {
  availability_zone       = data.aws_availability_zones.main.names[1]
  cidr_block              = var.public_cidr_2
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-public-2"
    },
    var.tags
  )
}

resource "aws_subnet" "public_3" {
  availability_zone       = data.aws_availability_zones.main.names[2]
  cidr_block              = var.public_cidr_3
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-public-3"
    },
    var.tags
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}"
    },
    var.tags
  )
}
resource "aws_default_route_table" "public" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-public"
    },
    var.tags
  )
}

resource "aws_subnet" "private_1" {
  availability_zone = data.aws_availability_zones.main.names[0]
  cidr_block        = var.private_cidr_1
  vpc_id            = aws_vpc.main.id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-private-1"
    },
    var.tags
  )
}

resource "aws_subnet" "private_2" {
  availability_zone = data.aws_availability_zones.main.names[1]
  cidr_block        = var.private_cidr_2
  vpc_id            = aws_vpc.main.id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-private-2"
    },
    var.tags
  )
}

resource "aws_subnet" "private_3" {
  availability_zone = data.aws_availability_zones.main.names[2]
  cidr_block        = var.private_cidr_3
  vpc_id            = aws_vpc.main.id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-private-3"
    },
    var.tags
  )
}
resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-private-1"
    },
    var.tags
  )
}

resource "aws_route_table" "private_2" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-private-2"
    },
    var.tags
  )
}

resource "aws_route_table" "private_3" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-private-3"
    },
    var.tags
  )
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_2.id
}

resource "aws_route_table_association" "private_3" {
  subnet_id      = aws_subnet.private_3.id
  route_table_id = aws_route_table.private_3.id
}

resource "aws_security_group" "nat_instance" {
  count       = var.nat == "instance" ? 1 : 0
  name        = "${var.project}-${var.environment}-nat-instance"
  description = "${var.project}-${var.environment}-nat-instance"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-nat-instance"
    },
    var.tags
  )

}

resource "aws_vpc_security_group_ingress_rule" "nat_ingress" {
  count             = var.nat == "instance" ? 1 : 0
  ip_protocol       = "-1"
  cidr_ipv4         = var.vpc_cidr
  security_group_id = aws_security_group.nat_instance[0].id

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-nat-ingress"
    },
    var.tags
  )
}

resource "aws_vpc_security_group_egress_rule" "nat_egress_ipv4" {
  count             = var.nat == "instance" ? 1 : 0
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.nat_instance[0].id

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-nat-egress-ipv4"
    },
    var.tags
  )
}

resource "aws_vpc_security_group_egress_rule" "nat_egress_ipv6" {
  count             = var.nat == "instance" ? 1 : 0
  ip_protocol       = "-1"
  cidr_ipv6         = "::/0"
  security_group_id = aws_security_group.nat_instance[0].id

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-nat-egress-ipv6"
    },
    var.tags
  )
}

resource "aws_iam_role" "nat_instance" {
  count = var.nat == "instance" ? 1 : 0

  name = "${var.project}-${var.environment}-nat-instance"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-nat-instance"
    },
    var.tags
  )
}

resource "aws_iam_role_policy" "nat_instance_ssm" {
  count = var.nat == "instance" ? 1 : 0

  name = "${var.project}-${var.environment}-nat-instance-ssm"
  role = aws_iam_role.nat_instance[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:UpdateInstanceInformation",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "nat_instance" {
  count = var.nat == "instance" ? 1 : 0

  name = "${var.project}-${var.environment}-nat-instance"
  role = aws_iam_role.nat_instance[0].name

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-nat-instance"
    },
    var.tags
  )
}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "nat" {
  count                       = var.nat == "instance" ? 3 : 0
  ami                         = data.aws_ssm_parameter.al2023_ami.value
  instance_type               = var.nat_instance_type
  iam_instance_profile        = aws_iam_instance_profile.nat_instance[0].name
  vpc_security_group_ids      = [aws_security_group.nat_instance[0].id]
  source_dest_check           = false
  subnet_id                   = [aws_subnet.public_1.id, aws_subnet.public_2.id, aws_subnet.public_3.id][count.index]
  user_data_replace_on_change = true
  user_data = trimspace(
    <<EOF
    #!/bin/bash
    sudo sysctl -w net.ipv4.ip_forward=1
    sudo dnf -y install iptables-services
    sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    sudo service iptables save
    sudo systemctl enable iptables
    sudo systemctl start iptables
  EOF
  )

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-nat-instance-${count.index + 1}"
    },
    var.tags
  )
}

resource "aws_nat_gateway" "gateway_1" {
  count             = var.nat == "gateway" ? 1 : 0
  connectivity_type = "public"
  allocation_id     = aws_eip.nat_1.allocation_id
  subnet_id         = aws_subnet.public_1.id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-1"
    },
    var.tags
  )
}

resource "aws_nat_gateway" "gateway_2" {
  count             = var.nat == "gateway" ? 1 : 0
  connectivity_type = "public"
  allocation_id     = aws_eip.nat_2.allocation_id
  subnet_id         = aws_subnet.public_2.id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-2"
    },
    var.tags
  )
}

resource "aws_nat_gateway" "gateway_3" {
  count             = var.nat == "gateway" ? 1 : 0
  connectivity_type = "public"
  allocation_id     = aws_eip.nat_3.allocation_id
  subnet_id         = aws_subnet.public_3.id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-3"
    },
    var.tags
  )
}

resource "aws_route" "private_1" {
  route_table_id         = aws_route_table.private_1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat == "gateway" ? aws_nat_gateway.gateway_1[0].id : null
  network_interface_id   = var.nat == "instance" ? aws_instance.nat[0].primary_network_interface_id : null
}

resource "aws_route" "private_2" {
  route_table_id         = aws_route_table.private_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat == "gateway" ? aws_nat_gateway.gateway_2[0].id : null
  network_interface_id   = var.nat == "instance" ? aws_instance.nat[1].primary_network_interface_id : null
}

resource "aws_route" "private_3" {
  route_table_id         = aws_route_table.private_3.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat == "gateway" ? aws_nat_gateway.gateway_3[0].id : null
  network_interface_id   = var.nat == "instance" ? aws_instance.nat[2].primary_network_interface_id : null
}

resource "aws_eip" "nat_1" {
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-nat-1"
    },
    var.tags
  )
  lifecycle {
    prevent_destroy = true #set true for safety measures
  }
}

resource "aws_eip" "nat_2" {
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-nat-2"
    },
    var.tags
  )
  lifecycle {
    prevent_destroy = true #set true for safety measures
  }
}

resource "aws_eip" "nat_3" {
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-nat-3"
    },
    var.tags
  )
  lifecycle {
    prevent_destroy = true #set true for safety measures
  }
}

resource "aws_eip_association" "nat_instance" {
  count         = var.nat == "instance" ? 3 : 0
  instance_id   = aws_instance.nat[count.index].id
  allocation_id = [aws_eip.nat_1.id, aws_eip.nat_2.id, aws_eip.nat_3.id][count.index]
}

resource "aws_security_group" "ssm_endpoints" {
  count       = var.enable_ssm_vpc_endpoints ? 1 : 0
  name        = "${var.project}-${var.environment}-ssm-endpoints"
  description = "Allow HTTPS from VPC to SSM VPC endpoints"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-ssm-endpoints"
    },
    var.tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "ssm_endpoints_ingress" {
  count             = var.enable_ssm_vpc_endpoints ? 1 : 0
  security_group_id = aws_security_group.ssm_endpoints[0].id
  description       = "HTTPS from VPC"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-ssm-endpoints-ingress"
    },
    var.tags
  )
}

resource "aws_vpc_endpoint" "ssm" {
  count = var.enable_ssm_vpc_endpoints ? 1 : 0

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.id}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_1.id, aws_subnet.private_2.id, aws_subnet.private_3.id]
  security_group_ids  = [aws_security_group.ssm_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-ssm"
    },
    var.tags
  )
}

