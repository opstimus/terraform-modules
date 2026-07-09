# Site-to-Site VPN Module

## Description

This Terraform module provisions an AWS Site-to-Site VPN including a Customer Gateway, a VPN Gateway attached to a VPC, the VPN Connection (IKEv2, AES256/SHA2-256, DPD restart), CloudWatch Log Groups for each tunnel, and routes to direct traffic for your on‑prem networks into specified route tables.

## Requirements

| Name       | Version  |
|------------|----------|
| terraform  | >= 1.3.0  |
| aws        | >= 6.0    |

## Providers

| Name     | Version |
|----------|---------|
| aws      | >= 6.0  |

## Inputs

| Name                          | Description                                         | Type            | Default | Required |
|-------------------------------|-----------------------------------------------------|-----------------|:-------:|:--------:|
| project                       | Project name                                        | `string`        | -       | yes      |
| environment                   | Environment name                                    | `string`        | -       | yes      |
| name                          | Resource name suffix used in tags                   | `string`        | -       | yes      |
| customer_gateway_ip_address   | Customer (on‑prem) public IP for the Customer GW    | `string`        | -       | yes      |
| device_name                   | Device name for the Customer Gateway tag            | `string`        | -       | yes      |
| vpc_id                        | VPC ID to attach the VPN Gateway                    | `string`        | -       | yes      |
| local_ipv4_network_cidr       | Remote (on‑prem) CIDR to route through the VPN      | `string`        | -       | yes      |
| route_table_ids               | List of route table IDs to create routes in         | `list(string)`  | `[]`    | yes      |

Notes:
- This module configures the VPN connection with static routes only and creates routes in every route table provided in `route_table_ids` using `for_each`.

## Outputs

| Name                                | Description |
|-------------------------------------|-------------|
| vpn_connection_id                   | ID of the aws_vpn_connection created |
| vpn_gateway_id                      | ID of the aws_vpn_gateway created |
| customer_gateway_id                 | ID of the aws_customer_gateway created |

## Usage example

```hcl
module "site_to_site_vpn" {
  source                        = "git::https://github.com/opstimus/terraform-modules.git//modules/aws-site-to-site-vpn?ref=aws-site-to-site-vpn/v<RELEASE>"
  project                       = "myproject"
  environment                   = "production"
  name                          = "s2s"
  customer_gateway_ip_address   = "123.123.123.123"
  device_name                   = "fortigate-fw"
  vpc_id                        = "vpc-1234567890"
  local_ipv4_network_cidr       = "192.168.1.0/24"
  route_table_ids               = ["rtb-0123abc", "rtb-0456def", "rtb-0789ghi"]
}
```

## Notes

- Routes are created dynamically for every entry in `route_table_ids` (no static per‑route resources required). Pass as many route table IDs as needed.
- The connection is configured with strong cryptographic defaults (IKEv2, AES256, SHA2‑256, multiple DH groups) and CloudWatch logging for each tunnel.
- If you need BGP, adjust the module to enable dynamic routing and expose `bgp_asn`/BGP configuration variables.
