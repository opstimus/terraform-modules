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
| aws | >= 4.0 | 

## Inputs 

| Name              | Description                        | Type    | Default | Required | 
|-------------------|------------------------------------|---------|---------|:--------:| 
| project           | Project name                       | string  | -       | yes      | 
| environment       | Environment name                   | string  | -       | yes      | 
| resource_name     | Resource name created KMS for      | string  | -       | yes      | 
| enable_key_rotation | Enable key rotation                | bool    | true    | no       | 

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
}

output "key_arn" {
  value = module.kms_key.key_arn
}
```

## Notes

The names for the created resources follow the pattern `{project}-{environment}-{resource_name}`.
