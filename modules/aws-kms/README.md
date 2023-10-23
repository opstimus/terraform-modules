# AWS KMS Key

## Description

This Terraform module creates a custom Amazon Key Management Service (KMS) key with an optional alias.

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
| project | The name of the project. | `string` | - | yes |
| environment | The name of the environment. | `string` | - | yes |
| resource_name | The name of the resource to create the KMS key for. | `string` | - | yes |
| enable_key_rotation | Whether to enable key rotation for the KMS key. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| key_arn | The ARN of the created KMS key. |

## Example Usage

```hcl
module "kms_key" {
  source            = "s3::https://s3.amazonaws.com/ot-turbo-artifacts/tf/modules/aws/dev/kms.zip"

  project           = "my_project"
  environment       = "my_environment"
  resource_name     = "my_resource"
  enable_key_rotation = true
}
```

## Notes

The names for the created resources follow the pattern `{project}-{environment}-{resource_name}`.
