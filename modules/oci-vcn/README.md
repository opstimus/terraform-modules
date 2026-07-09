# OCI VCN Module

## Description

Provisions an Oracle Cloud Infrastructure Virtual Cloud Network (VCN) with a complete network topology: an internet gateway and public route table for public subnets, a reserved public IP, a NAT gateway and per-subnet private route tables for private subnets, and a shared security list that allows all intra-VCN ingress and unrestricted egress.

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.3.0  |
| oci       | >= 8.0    |

## Providers

| Name | Version |
|------|---------|
| oci  | >= 8.0  |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project | The name of the project. | `string` | - | yes |
| environment | The environment (e.g., dev, prod). | `string` | - | yes |
| compartment_id | The OCID of the compartment where the VCN will be created. | `string` | - | yes |
| vcn_cidr_blocks | The CIDR blocks for the VCN. | `list(string)` | - | yes |
| public_subnets | A map of public subnet names to their CIDR blocks. | `map(string)` | - | yes |
| private_subnets | A map of private subnet names to their CIDR blocks. | `map(string)` | - | yes |
| tags | Free-form tags to apply to the VCN. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| vcn_id | The ID of the VCN. |
| vcn_cidr_blocks | The CIDR blocks of the VCN. |
| public_subnet_cidr_block | The CIDR block of the public subnet. |
| public_subnet_ids | The IDs of the public subnets. |
| private_subnet_cidr_block | The CIDR block of the private subnet. |
| private_subnet_ids | The IDs of the private subnets. |
| public_route_table_id | The ID of the public route table. |
| private_route_table_id | The ID of the private route table. |

## Usage examples

### Basic Usage Example

```hcl
module "vcn" {
  source = "git::https://github.com/opstimus/terraform-modules.git//modules/oci-vcn?ref=oci-vcn/v<RELEASE>"

  project        = "myapp"
  environment    = "prod"
  compartment_id = "ocid1.compartment.oc1..exampleuniqueID"
  vcn_cidr_blocks = ["10.0.0.0/16"]

  public_subnets = {
    "public-a" = "10.0.0.0/24"
    "public-b" = "10.0.1.0/24"
  }

  private_subnets = {
    "private-a" = "10.0.10.0/24"
    "private-b" = "10.0.11.0/24"
  }
}
```
