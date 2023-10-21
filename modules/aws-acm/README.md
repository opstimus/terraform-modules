# AWS ACM Certificate

## Description

This Terraform module creates an ACM (Amazon Certificate Manager) Certificate and validates it.

The module allows configuring the certificate to be either domain-specific or a wildcard certificate.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project | The project name. | `string` | - | yes |
| environment | The environment name. | `string` | - | yes |
| domain | The domain for which the certificate should be issued, e.g., "example.com". | `string` | - | yes |
| wildcard | If set to `true`, a wildcard certificate will be issued. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| certificate_arn | The ARN (Amazon Resource Name) of the issued certificate. |

## Example Usage

```hcl
module "acm_certificate" {
  source      = "s3::https://s3.amazonaws.com/ot-turbo-artifacts/tf/modules/aws/dev/acm.zip"

  project     = "my_project"
  environment = "my_environment"
  domain      = "example.com"
  wildcard    = true
}
```
