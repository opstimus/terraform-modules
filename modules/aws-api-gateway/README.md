# API Gateway Module

## Description

This Terraform module creates and manages an AWS API Gateway with associated stages, deployments, and domain name mappings. It also configures CORS settings for the API.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.3.0 |
| aws       | >= 4.0   |

## Providers

| Name | Version  |
|------|----------|
| aws  | >= 4.0   |

## Inputs

| Name              | Description            | Type           | Default | Required |
|-------------------|------------------------|----------------|---------|:--------:|
| project           | Project name           | `string`       | -       | yes      |
| environment       | Environment name       | `string`       | -       | yes      |
| name              | API name               | `string`       | -       | yes      |
| cors_allow_origins| CORS allowed origins   | `list(string)` | -       | yes      |
| cors_allow_methods| CORS allowed methods   | `list(string)` | ["*"]   | no       |
| cors_allow_headers| CORS allowed headers   | `list(any)`    | ["*"]   | no       |
| cors_max_age      | CORS max age           | `number`       | 5       | no       |
| api_version       | API version            | `string`       | "1.0"   | no       |
| body              | API body               | `string`       | null    | no       |
| domain_name       | Custom domain name     | `string`       | null    | no       |
| certificate_arn   | Certificate ARN        | `string`       | null    | no       |

## Outputs

| Name         | Description           |
|--------------|-----------------------|
| execution_arn| The execution ARN of the API |

## Usage examples

### Example usage of the module

```hcl
module "api_gateway" {
  source             = "path_to_your_module"
  project            = "my_project"
  environment        = "prod"
  name               = "my_api"
  cors_allow_origins = ["https://example.com"]
  cors_allow_methods = ["GET", "POST"]
  cors_allow_headers = ["Authorization"]
  cors_max_age       = 3600
  api_version        = "1.0"
  body               = null
  domain_name        = "api.example.com"
  certificate_arn    = "arn:aws:acm:region:account:certificate/certificate_id"
}
