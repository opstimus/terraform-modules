# Secrets Manager Module

## Description

This Terraform module creates and manages AWS Secrets Manager secrets. It allows you to store a secure string, optionally generating a random password if no string is provided. The module also outputs the secret name and ARN.

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.3.0  |
| aws       | >= 6.0    |

## Providers

| Name  | Version |
|-------|---------|
| aws   | >= 6.0  |
| random| >= 3.4.0|

## Inputs

| Name          | Description                        | Type   | Default | Required |
|---------------|------------------------------------|--------|---------|:--------:|
| project       | Project name                       | string | -       |   yes    |
| environment   | Environment name                   | string | -       |   yes    |
| name          | Secret name (e.g., mail-password)  | string | -       |   yes    |
| secret_string | The secret string to store; set to `"random"` to auto-generate a value | string | null    |   no   |
| tags          | A map of tags to assign to the secret | map(string) | {} | no |
| random_length | Length of the generated value when `secret_string = "random"` | number | 16 | no |
| random_special | Whether the generated value may include special characters when `secret_string = "random"` | bool | true | no |
| random_override_special | Set of special characters allowed when `random_special` is true | string | `!#$%&*?` | no |

## Outputs

| Name        | Description                       |
|-------------|-----------------------------------|
| secret_name | The name of the Secrets Manager secret |
| secret_arn  | The ARN of the Secrets Manager secret  |

## Usage examples

### Basic Secrets Manager Setup

This example shows how to use the Secrets Manager module to create a secret with a random password.

```hcl
module "secrets_manager" {
  source        = "git::https://github.com/opstimus/terraform-modules.git//modules/aws-secret?ref=aws-secret/v<RELEASE>"
  project       = "my-project"
  environment   = "dev"
  name          = "db-password"
  secret_string = "random"
  tags = {
    Project = <project-name>
    Environment = <environment-name>
  }
}
```

### Random password with custom length and charset

Generate a 64-character alphanumeric value (no special characters).

```hcl
module "secrets_manager" {
  source         = "git::https://github.com/opstimus/terraform-modules.git//modules/aws-secret?ref=aws-secret/v<RELEASE>"
  project        = "my-project"
  environment    = "dev"
  name           = "api-key"
  secret_string  = "random"
  random_length  = 64
  random_special = false
}
```
