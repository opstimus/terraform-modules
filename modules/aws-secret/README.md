# Secrets Manager Module

## Description

This Terraform module creates and manages AWS Secrets Manager secrets. It allows you to store a secure string, optionally generating a random password if no string is provided. The module also outputs the secret name and ARN.

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.3.0  |
| aws       | >= 4.0    |

## Providers

| Name  | Version |
|-------|---------|
| aws   | >= 4.0  |
| random| >= 3.4.0|

## Inputs

| Name          | Description                        | Type   | Default | Required |
|---------------|------------------------------------|--------|---------|:--------:|
| project       | Project name                       | string | -       |   yes    |
| environment   | Environment name                   | string | -       |   yes    |
| name          | Secret name (e.g., mail-password)  | string | -       |   yes    |
| secret_string | The secret string to store         | string | null    |    no    |

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
  source        = "github.com/opstimus/terraform-aws-secret?ref=v<RELEASE>"

  project       = "my-project"
  environment   = "dev"
  name          = "db-password"
  secret_string = "random"
}
```
