# AWS KMS Key Module

## Description

This Terraform module provisions an AWS KMS (Key Management Service) key and an associated alias. It enables you to create a custom KMS key with optional key rotation and tag it with specific project and environment details.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 6.0 |

## Inputs

| Name              | Description                        | Type    | Default | Required |
|-------------------|------------------------------------|---------|---------|:--------:|
| project           | Project name                       | string  | -       | yes      |
| environment       | Environment name                   | string  | -       | yes      |
| resource_name     | Resource name created KMS for      | string  | -       | yes      |
| enable_key_rotation | Enable key rotation                | bool    | true    | no       |
| tags              | tags                               | map(string)  | {}  | no       |
| key_policy_statements | Additional key policy statements (merged with default root statement) | list(object) | [] | no |

## Outputs

| Name    | Description       |
|---------|-------------------|
| key_arn | The ARN of the KMS key |

## Usage examples

### Example 1: Basic usage of the module

```hcl
module "kms_key" {
  source              = "github.com/opstimus/terraform-aws-kms?ref=v<RELEASE>"
  project             = "my-project"
  environment         = "dev"
  resource_name       = "my-key"
  enable_key_rotation = true
  tags = {
    Name        = <project-name>
    Environment = <environment-name>
  }
}

output "key_arn" {
  value = module.kms_key.key_arn
}
```

### Example 2: Key with custom policy (e.g. Aurora DSQL)

```hcl
module "kms_key" {
  source        = "github.com/opstimus/terraform-aws-kms?ref=v<RELEASE>"
  project       = "my-project"
  environment   = "dev"
  resource_name = "my-dsql-key"

  key_policy_statements = [
    {
      sid    = "Allow Aurora DSQL"
      effect = "Allow"
      principals = [{ type = "Service", identifiers = ["dsql.amazonaws.com"] }]
      actions = [
        "kms:Decrypt", "kms:GenerateDataKey", "kms:GenerateDataKeyWithoutPlaintext",
        "kms:Encrypt", "kms:ReEncryptFrom", "kms:ReEncryptTo", "kms:DescribeKey"
      ]
      resources = ["*"]
    }
  ]
}
```

## Notes

The names for the created resources follow the pattern `{project}-{environment}-{resource_name}`.
