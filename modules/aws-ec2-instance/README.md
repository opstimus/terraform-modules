# EC2 Instance with Security Group Module

## Description

This Terraform module provisions an EC2 instance within a specified VPC and subnet. It includes optional security group creation, Elastic IP attachment, and allows for custom user data scripts. The module also supports the creation of ingress rules for the security group and provides the instance ID as an output.

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.3.0  |
| aws       | >= 6.0    |

## Providers

| Name | Version |
|------|---------|
| aws  | >= 6.0  |

## Inputs

| Name                 | Description                          | Type          | Default     | Required |
|----------------------|--------------------------------------|---------------|-------------|:--------:|
| project              | Project name                         | string        | -           |   yes    |
| environment          | Environment name                     | string        | -           |   yes    |
| name                 | Instance name                        | string        | -           |   yes    |
| instance_type        | EC2 instance type                    | string        | "t3.micro"  |    no    |
| root_volume_size     | Volume size in GB                    | number        | 10          |    no    |
| ami                  | AMI ID                               | string        | "AMI ID"    |    no    |
| subnet_id            | Subnet ID for the instance           | string        | -           |   yes    |
| enable_eip           | Enable and attach Elastic IP         | bool          | false       |    no    |
| user_data            | User data script                     | string        | -           |    no    |
| source_dest_check    | Enable source/destination check      | bool          | true        |    no    |
| security_group_ids   | List of existing security group IDs  | list(any)     | []          |    no    |
| vpc_id               | VPC ID needed to create security group| string       | null        |    no    |
| ingress_rules        | Map of security group ingress rules  | map(object)  | {}          |    no    |
| ingress_rules.from_port | Starting port for the ingress rule | number       | -           |   yes*   |
| ingress_rules.to_port   | Ending port for the ingress rule   | number       | -           |   yes*   |
| ingress_rules.ip_protocol | IP protocol (tcp, udp, icmp, etc.) | string       | -           |   yes*   |
| ingress_rules.cidr_ipv4  | List of IPv4 CIDR blocks            | list(string) | -           |   yes*   |
| ingress_rules.description | Description for the ingress rule    | string       | null        |    no    |
| key_name             | Key pair name for the instance       | string        | null        |    no    |
| termination_protection | Enable termination protection       | bool          | false       |    no    |
| iam_instance_profile | IAM Instance Profile to launch the instance with | string | null | no |

## Outputs

| Name        | Description             |
|-------------|-------------------------|
| instance_id | The ID of the EC2 instance |

## Usage examples

### Basic EC2 Instance with Security Group

This example demonstrates how to use the module to create an EC2 instance with a security group that allows ingress traffic on specific ports.

```hcl
module "ec2_instance" {
  source              = "github.com/opstimus/terraform-aws-ec2-instance?ref=v<RELEASE>"

  project             = "my-project"
  environment         = "dev"
  name                = "web-server"
  instance_type       = "t3.medium"
  root_volume_size    = 20
  ami                 = "ami-12345678"
  subnet_id           = "subnet-0bb1c79de3EXAMPLE"
  enable_eip          = true
  user_data = replace(
    file("userdata.sh"),
    "\r\n",
    "\n"
  )
  source_dest_check   = true
  vpc_id              = "vpc-0a1b2c3d4eEXAMPLE"
  ingress_rules = {
    "HTTP" = {
      from_port   = 80,
      to_port     = 80,
      ip_protocol = "tcp",
      cidr_ipv4   = ["0.0.0.0/0"],
      description = "Allow HTTP traffic"
    },
    "HTTPS" = {
      from_port   = 443,
      to_port     = 443,
      ip_protocol = "tcp",
      cidr_ipv4   = ["0.0.0.0/0"],
      description = "Allow HTTPS traffic"
    }
  }
}
```
