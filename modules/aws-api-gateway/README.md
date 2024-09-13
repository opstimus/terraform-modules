# API Gateway Module

## Description

This Terraform module creates an AWS API Gateway v2 resource with CORS configuration, stages, and optional custom domain mappings. It supports defining a full HTTP API with deployment and optional domain name configuration.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.3.0 |
| aws       | >= 4.0   |

## Providers

| Name | Version |
|------|---------|
| aws  | >= 4.0  |

## Inputs

| Name              | Description                                | Type          | Default          | Required |
|-------------------|--------------------------------------------|---------------|------------------|:--------:|
| project           | Project name                               | `string`      | `-`              | yes      |
| environment       | Environment name                           | `string`      | `-`              | yes      |
| name              | API name                                   | `string`      | `-`              | yes      |
| cors_allow_origins| List of allowed origins for CORS           | `list(string)`| `-`              | yes      |
| cors_allow_methods| List of allowed methods for CORS           | `list(string)`| `["*"]`          | no       |
| cors_allow_headers| List of allowed headers for CORS           | `list(any)`   | `["*"]`          | no       |
| cors_max_age      | Maximum age for CORS preflight requests    | `number`      | `5`              | no       |
| api_version       | Version of the API                         | `string`      | `"1.0"`          | no       |
| body              | OpenAPI definition for the API             | `string`      | `null`           | no       |
| domain_name       | Custom domain name for the API             | `string`      | `null`           | no       |
| certificate_arn   | ARN of the SSL certificate for the domain  | `string`      | `null`           | no       |

## Outputs

| Name           | Description                                  |
|----------------|----------------------------------------------|
| execution_arn  | The execution ARN of the created API Gateway |

## Usage examples

### Basic Usage

```hcl
module "api_gateway" {
  source              = "github.com/opstimus/terraform-aws-api-gateway?ref=v<RELEASE>"

  project             = "example-project"
  environment         = "dev"
  name                = "example-api"
  cors_allow_origins  = ["*"]

  # Optional configurations
  api_version         = "1.0"
  domain_name         = "api.example.com"
  certificate_arn     = "arn:aws:acm:region:account-id:certificate/certificate-id"
}
```
