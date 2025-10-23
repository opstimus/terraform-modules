# EFS Module

## Description

This Terraform module creates a EFS along with mount targets and its own security group.

## Requirements

| Name       | Version  |
|------------|----------|
| terraform  | >= 1.3.0 |
| aws        | >= 4.0   |

## Providers

| Name | Version |
|------|---------|
| aws  | >= 4.0  |

## Inputs

| Name               | Description               | Type     | Default     | Required |
|--------------------|---------------------------|----------|-------------|:--------:|
| project            | Project name              | `string` | -           | yes      |
| environment        | Environment name          | `string` | -           | yes      |
| name               | Name of service           | `string` | -           | yes      |
| kms_key_id         | ARN value of KMS          | `string` | -           | no       |
| subnet_ids         | Public / Private subnets Ids | `list(string)` | -  | yes      |

## Outputs

| Name           | Description               |
|----------------|---------------------------|
| efs_arn        | The ARN of the efs        |
| efs_dns_name   | The DNS value of efs      |
| efs_name       | The name efs              |


## Usage examples

### Example 1: Basic EFS Creation

```hcl
module "efs" {
  source          = "github.com/opstimus/terraform-aws-efs?ref=v<RELEASE>"
  project         = "myproject"
  environment     = "production"
  name            = "store"
  kms_key_id      = "arn:aws:kms:arnValue"
  subnet_ids      = ["subnet-123", "subnet-456"]
}
```