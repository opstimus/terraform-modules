# AWS Aurora DSQL Module

## Description

Provisions a single AWS Aurora DSQL cluster with optional KMS encryption and configurable deletion protection. The cluster is tagged using a combination of the project, environment, and resource name variables.

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

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project | Project name | `string` | - | yes |
| environment | Environment name | `string` | - | yes |
| name | Resource name | `string` | - | yes |
| kms_key_arn | KMS key ARN | `string` | - | yes |
| deletion_protection_enabled | Deletion protection enabled | `bool` | `true` | no |

## Usage examples

### Basic Usage Example

```hcl
module "aurora_dsql" {
  source = "git::https://github.com/opstimus/terraform-modules.git//modules/aws-aurora-dsql?ref=aws-aurora-dsql/v<RELEASE>"

  project     = "myapp"
  environment = "prod"
  name        = "primary"
  kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/mrk-abc123"
}
```
