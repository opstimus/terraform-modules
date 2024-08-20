# AWS VPC with Subnets

## Description

This Terraform module creates an AWS Virtual Private Cloud (VPC) with public and private subnets. It also provisions an Internet Gateway and sets up route tables for public and private subnets.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | ~> 4.0 |
| external | >= 2.2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 4.0 |
| external | >= 2.2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project | Project name | `string` | - | yes |
| environment | Environment name | `string` | - | yes |
| nat | Valid values: gateway / instance | `string` | - | yes |
| nat_instance_type | Instance type for NAT instances | `string` | "t3.nano" | no |
| vpc_cidr | VPC CIDR block | `string` | - | yes |
| public_cidr_1 | CIDR block for public subnet 1 | `string` | - | yes |
| public_cidr_2 | CIDR block for public subnet 2 | `string` | - | yes |
| public_cidr_3 | CIDR block for public subnet 3 | `string` | - | yes |
| private_cidr_1 | CIDR block for private subnet 1 | `string` | - | yes |
| private_cidr_2 | CIDR block for private subnet 2 | `string` | - | yes |
| private_cidr_3 | CIDR block for private subnet 3 | `string` | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_cidr | The CIDR block of the VPC |
| public_subnets | Comma-separated list of public subnet IDs |
| private_subnets | Comma-separated list of private subnet IDs |

## Example Usage

```hcl
module "vpc" {
  source             = "github.com/opstimus/terraform-aws-vpc?ref=v1.0.1"

  project            = "my_project"
  environment        = "my_environment"
  nat                = "instance"
  nat_instance_type  = "t3.nano"
  vpc_cidr           = "10.0.0.0/16"
  public_cidr_1      = "10.0.1.0/24"
  public_cidr_2      = "10.0.2.0/24"
  public_cidr_3      = "10.0.3.0/24"
  private_cidr_1     = "10.0.10.0/24"
  private_cidr_2     = "10.0.11.0/24"
  private_cidr_3     = "10.0.12.0/24"
}
```

## Notes

The `nat` variable in the module controls whether you want to use an EC2 instance or a NAT gateway for internet access in your private subnets.
