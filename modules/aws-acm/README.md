# ACM Certificate Module

## Description

This Terraform module provisions an AWS ACM (Amazon Certificate Manager) certificate for a given domain. It supports the creation of both regular and wildcard certificates and validates the certificate using DNS validation.

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

| Name        | Description                    | Type    | Default | Required |
|-------------|--------------------------------|---------|---------|:--------:|
| project     | Project name                   | string  | -       |   yes    |
| environment | Environment name               | string  | -       |   yes    |
| domain      | Domain for the certificate      | string  | -       |   yes    |
| wildcard    | Create wildcard certificate    | bool    | false   |    no    |
| tags        | tags                           | `map(string)` | -       |    no    |

## Outputs

| Name            | Description                   |
|-----------------|-------------------------------|
| certificate_arn | The ARN of the validated ACM certificate |

## Usage examples

### Basic ACM Certificate with Wildcard Support

This example demonstrates how to use the module to create an ACM certificate with an optional wildcard domain.

```hcl
module "acm_certificate" {
  source      = "git::https://github.com/opstimus/terraform-modules.git//modules/aws-acm?ref=aws-acm/v<RELEASE>"
  project     = "my-project"
  environment = "production"
  domain      = "example.com"
  wildcard    = true
  tags = {
    Project = <project-name>
    Environment = <environment-name>
  }
}
```
