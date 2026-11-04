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

resource "aws_iam_role_policy" "nat_instance_ready_tag" {
  count = var.nat == "instance" ? 1 : 0

  name = "${var.project}-${var.environment}-nat-instance-ready-tag"
  role = aws_iam_role.nat_instance[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ec2:CreateTags"
        Resource = "arn:aws:ec2:*:*:instance/*"
        Condition = {
          StringEquals = {
            "aws:ARN" = "$${ec2:SourceInstanceARN}"
          }
          "ForAllValues:StringEquals" = {
            "aws:TagKeys" = ["NatReady"]
          }
        }
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
  user_data                   = <<-EOF
    #!/bin/bash
    set -xe
    # temporary swap so dnf survives on 512MB
    fallocate -l 1G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    dnf install -y --setopt=install_weak_deps=False iptables
    swapoff /swapfile
    rm -f /swapfile

    echo "net.ipv4.ip_forward=1" | tee /etc/sysctl.d/99-nat.conf
    sysctl -p /etc/sysctl.d/99-nat.conf
    ETH=$(ip route show default | awk '{print $5}')
    iptables -t nat -A POSTROUTING -o $ETH -j MASQUERADE
    mkdir -p /etc/iptables
    iptables-save > /etc/iptables/rules.v4
    printf '[Unit]\nDescription=Restore iptables NAT rules\nAfter=network.target\n\n[Service]\nType=oneshot\nExecStart=/sbin/iptables-restore /etc/iptables/rules.v4\nRemainAfterExit=yes\n\n[Install]\nWantedBy=multi-user.target\n' > /etc/systemd/system/iptables-restore.service
    systemctl daemon-reload
    systemctl enable iptables-restore.service

    # Signal readiness so Terraform moves the EIP and private route only now
    TOKEN=$(curl -sX PUT http://169.254.169.254/latest/api/token -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
    ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
    REGION=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region)
    for i in $(seq 1 30); do
      aws ec2 create-tags --region "$REGION" --resources "$ID" --tags Key=NatReady,Value=true && break
      sleep 10
    done
  EOF

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

  # Replacements (e.g. a new AMI) bring the new NAT up before the old one goes
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_iam_role_policy.nat_instance_ready_tag]
}

# Waits for the new NAT's readiness tag, so the EIP and private route switch
# over only once it is forwarding. On timeout the apply fails and traffic
# stays on the old NAT.
resource "terraform_data" "nat_ready" {
  count            = var.nat == "instance" ? 3 : 0
  triggers_replace = aws_instance.nat[count.index].id
  input = {
    instance_id          = aws_instance.nat[count.index].id
    network_interface_id = aws_instance.nat[count.index].primary_network_interface_id
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      for i in $(seq 1 60); do
        READY=$(aws ec2 describe-tags --region "${data.aws_region.current.region}" \
          --filters "Name=resource-id,Values=${self.input.instance_id}" "Name=key,Values=NatReady" \
          --query 'length(Tags)' --output text)
        if [ "$READY" = "1" ]; then
          echo "NAT ${self.input.instance_id} is ready"
          exit 0
        fi
        sleep 10
      done
      echo "Timed out waiting for NAT ${self.input.instance_id} to become ready" >&2
      exit 1
    EOT
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_metric_alarm" "nat_system_status" {
  count               = var.nat == "instance" && var.enable_nat_alarms ? 3 : 0
  alarm_name          = "${var.project}-${var.environment}: NAT instance ${count.index + 1} system status check failed"
  alarm_description   = "NAT instance system status check failed; EC2 auto-recover triggered"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
  alarm_actions       = [var.alarm_sns_arn, "arn:aws:automate:${data.aws_region.current.region}:ec2:recover"]
  ok_actions          = [var.alarm_sns_arn]
  dimensions = {
    InstanceId = aws_instance.nat[count.index].id
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "nat_instance_status" {
  count               = var.nat == "instance" && var.enable_nat_alarms ? 3 : 0
  alarm_name          = "${var.project}-${var.environment}: NAT instance ${count.index + 1} instance status check failed"
  alarm_description   = "NAT instance status check failed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed_Instance"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
  alarm_actions       = [var.alarm_sns_arn]
  ok_actions          = [var.alarm_sns_arn]
  dimensions = {
    InstanceId = aws_instance.nat[count.index].id
  }
  tags = var.tags
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
  network_interface_id   = var.nat == "instance" ? terraform_data.nat_ready[0].output.network_interface_id : null
}

resource "aws_route" "private_2" {
  route_table_id         = aws_route_table.private_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat == "gateway" ? aws_nat_gateway.gateway_2[0].id : null
  network_interface_id   = var.nat == "instance" ? terraform_data.nat_ready[1].output.network_interface_id : null
}

resource "aws_route" "private_3" {
  route_table_id         = aws_route_table.private_3.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat == "gateway" ? aws_nat_gateway.gateway_3[0].id : null
  network_interface_id   = var.nat == "instance" ? terraform_data.nat_ready[2].output.network_interface_id : null
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
  instance_id   = terraform_data.nat_ready[count.index].output.instance_id
  allocation_id = [aws_eip.nat_1.id, aws_eip.nat_2.id, aws_eip.nat_3.id][count.index]

  lifecycle {
    create_before_destroy = true
  }
}

# Isolated subnets (no outbound internet access)
resource "aws_subnet" "isolated_1" {
  count             = var.enable_isolated_subnets ? 1 : 0
  availability_zone = data.aws_availability_zones.main.names[0]
  cidr_block        = var.isolated_cidr_1
  vpc_id            = aws_vpc.main.id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-isolated-1"
    },
    var.tags
  )
}

resource "aws_subnet" "isolated_2" {
  count             = var.enable_isolated_subnets ? 1 : 0
  availability_zone = data.aws_availability_zones.main.names[1]
  cidr_block        = var.isolated_cidr_2
  vpc_id            = aws_vpc.main.id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-isolated-2"
    },
    var.tags
  )
}

resource "aws_subnet" "isolated_3" {
  count             = var.enable_isolated_subnets ? 1 : 0
  availability_zone = data.aws_availability_zones.main.names[2]
  cidr_block        = var.isolated_cidr_3
  vpc_id            = aws_vpc.main.id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-isolated-3"
    },
    var.tags
  )
}

resource "aws_route_table" "isolated_1" {
  count  = var.enable_isolated_subnets ? 1 : 0
  vpc_id = aws_vpc.main.id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-isolated-1"
    },
    var.tags
  )
}

resource "aws_route_table" "isolated_2" {
  count  = var.enable_isolated_subnets ? 1 : 0
  vpc_id = aws_vpc.main.id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-isolated-2"
    },
    var.tags
  )
}

resource "aws_route_table" "isolated_3" {
  count  = var.enable_isolated_subnets ? 1 : 0
  vpc_id = aws_vpc.main.id
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-isolated-3"
    },
    var.tags
  )
}

resource "aws_route_table_association" "isolated_1" {
  count          = var.enable_isolated_subnets ? 1 : 0
  subnet_id      = aws_subnet.isolated_1[0].id
  route_table_id = aws_route_table.isolated_1[0].id
}

resource "aws_route_table_association" "isolated_2" {
  count          = var.enable_isolated_subnets ? 1 : 0
  subnet_id      = aws_subnet.isolated_2[0].id
  route_table_id = aws_route_table.isolated_2[0].id
}

resource "aws_route_table_association" "isolated_3" {
  count          = var.enable_isolated_subnets ? 1 : 0
  subnet_id      = aws_subnet.isolated_3[0].id
  route_table_id = aws_route_table.isolated_3[0].id
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
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ssm"
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

