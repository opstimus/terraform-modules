

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

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }


  # All traffic enabled for outbound. Restrict if required
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-nat-instance"
    },
    var.tags
  )

}

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}

resource "aws_instance" "nat_1" {
  count                       = var.nat == "instance" ? 1 : 0
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.nat_instance_type
  vpc_security_group_ids      = [aws_security_group.nat_instance[0].id]
  source_dest_check           = false
  subnet_id                   = aws_subnet.public_1.id
  user_data_replace_on_change = true
  user_data = trimspace(
    <<EOF
    #!/bin/bash
    sudo sysctl -w net.ipv4.ip_forward=1
    sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    sudo yum -y install iptables-services
    sudo service iptables save
  EOF
  )

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-nat-instance-1"
    },
    var.tags
  )

}

resource "aws_instance" "nat_2" {
  count                       = var.nat == "instance" ? 1 : 0
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.nat_instance_type
  vpc_security_group_ids      = [aws_security_group.nat_instance[0].id]
  source_dest_check           = false
  subnet_id                   = aws_subnet.public_2.id
  user_data_replace_on_change = true
  user_data = trimspace(
    <<EOF
    #!/bin/bash
    sudo sysctl -w net.ipv4.ip_forward=1
    sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    sudo yum -y install iptables-services
    sudo service iptables save
  EOF
  )

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-nat-instance-2"
    },
    var.tags
  )

}

resource "aws_instance" "nat_3" {
  count                       = var.nat == "instance" ? 1 : 0
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.nat_instance_type
  vpc_security_group_ids      = [aws_security_group.nat_instance[0].id]
  source_dest_check           = false
  subnet_id                   = aws_subnet.public_3.id
  user_data_replace_on_change = true
  user_data = trimspace(
    <<EOF
    #!/bin/bash
    sudo sysctl -w net.ipv4.ip_forward=1
    sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    sudo yum -y install iptables-services
    sudo service iptables save
  EOF
  )

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-nat-instance-3"
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
  network_interface_id   = var.nat == "instance" ? aws_instance.nat_1[0].primary_network_interface_id : null
}

resource "aws_route" "private_2" {
  route_table_id         = aws_route_table.private_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat == "gateway" ? aws_nat_gateway.gateway_2[0].id : null
  network_interface_id   = var.nat == "instance" ? aws_instance.nat_2[0].primary_network_interface_id : null
}

resource "aws_route" "private_3" {
  route_table_id         = aws_route_table.private_3.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat == "gateway" ? aws_nat_gateway.gateway_3[0].id : null
  network_interface_id   = var.nat == "instance" ? aws_instance.nat_3[0].primary_network_interface_id : null
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

resource "aws_eip_association" "nat_instance_1" {
  count         = var.nat == "instance" ? 1 : 0
  instance_id   = aws_instance.nat_1[0].id
  allocation_id = aws_eip.nat_1.id
}

resource "aws_eip_association" "nat_instance_2" {
  count         = var.nat == "instance" ? 1 : 0
  instance_id   = aws_instance.nat_2[0].id
  allocation_id = aws_eip.nat_2.id
}

resource "aws_eip_association" "nat_instance_3" {
  count         = var.nat == "instance" ? 1 : 0
  instance_id   = aws_instance.nat_3[0].id
  allocation_id = aws_eip.nat_3.id
}
