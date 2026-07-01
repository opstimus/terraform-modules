# VPC Module

## Description

This Terraform module creates a Virtual Private Cloud (VPC) along with associated subnets, route tables, NAT gateways, and security groups on AWS. The module allows you to deploy both public and private subnets across multiple availability zones, along with the option to use either NAT instances or NAT gateways for outbound internet access from the private subnets. Optionally, isolated private subnets with no outbound internet access can also be created.

## Requirements

| Name       | Version  |
|------------|----------|
| terraform  | >= 1.3.0 |
| aws        | >= 6.0   |
| external | >= 2.2.0 |

## Providers

| Name | Version |
|------|---------|
| aws  | >= 6.0  |
| external | >= 2.2.0 |

## Inputs

| Name               | Description               | Type     | Default     | Required |
|--------------------|---------------------------|----------|-------------|:--------:|
| project            | Project name              | `string` | -           | yes      |
| environment        | Environment name          | `string` | -           | yes      |
| nat                | NAT type: gateway/instance | `string` | -           | yes      |
| nat_instance_type  | NAT instance type         | `string` | `"t3.nano"` | no       |
| vpc_cidr           | VPC CIDR block            | `string` | -           | yes      |
| public_cidr_1      | Public subnet CIDR block  | `string` | -           | yes      |
| public_cidr_2      | Public subnet CIDR block  | `string` | -           | yes      |
| public_cidr_3      | Public subnet CIDR block  | `string` | -           | yes      |
| private_cidr_1     | Private subnet CIDR block | `string` | -           | yes      |
| private_cidr_2     | Private subnet CIDR block | `string` | -           | yes      |
| private_cidr_3     | Private subnet CIDR block | `string` | -           | yes      |
| enable_ssm_vpc_endpoints | Create VPC interface endpoint for SSM in private subnets | `bool` | `false` | no       |
| enable_isolated_subnets | Create isolated private subnets with no outbound internet access | `bool` | `false` | no       |
| isolated_cidr_1        | Isolated subnet CIDR for AZ 1. Required when enable_isolated_subnets is true | `string` | `null` | no       |
| isolated_cidr_2        | Isolated subnet CIDR for AZ 2. Required when enable_isolated_subnets is true | `string` | `null` | no       |
| isolated_cidr_3        | Isolated subnet CIDR for AZ 3. Required when enable_isolated_subnets is true | `string` | `null` | no       |

## Outputs

| Name           | Description             |
|----------------|-------------------------|
| vpc_id         | The ID of the VPC        |
| vpc_cidr       | The CIDR block of the VPC |
| public_subnets | List of public subnet IDs |
| private_subnets | List of private subnet IDs |
| public_route_tables_id  | Public route table ID|
| private_route_tables_ids | List of private route table IDs |
| isolated_subnets | List of isolated subnet IDs (null when disabled) |
| isolated_route_tables_ids | List of isolated route table IDs (null when disabled) |

## Usage examples

### Example 1: Basic VPC Setup with NAT Gateway

```hcl
module "vpc" {
  source          = "github.com/opstimus/terraform-aws-vpc?ref=v<RELEASE>"
  project         = "myproject"
  environment     = "production"
  vpc_cidr        = "10.0.0.0/16"
  public_cidr_1   = "10.0.1.0/24"
  public_cidr_2   = "10.0.2.0/24"
  public_cidr_3   = "10.0.3.0/24"
  private_cidr_1  = "10.0.4.0/24"
  private_cidr_2  = "10.0.5.0/24"
  private_cidr_3  = "10.0.6.0/24"
  nat             = "gateway"
}
```

### Example 2: VPC with Isolated Subnets

```hcl
module "vpc" {
  source          = "github.com/opstimus/terraform-aws-vpc?ref=v<RELEASE>"
  project         = "myproject"
  environment     = "production"
  vpc_cidr        = "10.0.0.0/16"
  public_cidr_1   = "10.0.1.0/24"
  public_cidr_2   = "10.0.2.0/24"
  public_cidr_3   = "10.0.3.0/24"
  private_cidr_1  = "10.0.4.0/24"
  private_cidr_2  = "10.0.5.0/24"
  private_cidr_3  = "10.0.6.0/24"
  nat             = "gateway"

  enable_isolated_subnets = true
  isolated_cidr_1         = "10.0.7.0/24"
  isolated_cidr_2         = "10.0.8.0/24"
  isolated_cidr_3         = "10.0.9.0/24"
}
```

## Notes

- The `nat` variable controls whether to use an EC2 instance or a NAT gateway for internet access in private subnets.
- Isolated subnets have **no outbound internet access** — their route tables contain no default route. They can only communicate within the VPC. Use them for resources that must never reach the internet (e.g. databases, internal services).
- `isolated_cidr_1/2/3` are required when `enable_isolated_subnets = true`.
