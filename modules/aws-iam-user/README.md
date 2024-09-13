# IAM User Module

## Description

This Terraform module creates an AWS IAM user with an associated user policy and stores the IAM user's access and secret keys in AWS Secrets Manager.

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.3.0  |
| aws       | >= 4.0    |

## Providers

| Name     | Version   |
|----------|-----------|
| aws      | >= 4.0    |
| external | >= 2.2.0  |
| random   | >= 3.4.0  |
| time     | >= 0.9    |

## Inputs

| Name        | Description       | Type   | Default | Required |
|-------------|-------------------|--------|---------|:--------:|
| project     | Project name       | string | -       |   yes    |
| environment | Environment name   | string | -       |   yes    |
| name        | User name          | string | -       |   yes    |
| user_policy | IAM user policy    | string | -       |   yes    |

## Outputs

| Name        | Description                               |
|-------------|-------------------------------------------|
| iam_user_id | The ID of the created IAM user            |
| iam_user_arn| The ARN of the created IAM user           |

## Usage examples

### Basic IAM User Setup

This example demonstrates how to use the IAM User module to create a user with a specific policy and store their access and secret keys in AWS Secrets Manager.

```hcl
module "iam_user" {
  source        = "github.com/opstimus/terraform-aws-iam-user?ref=v<RELEASE>"

  project       = "my-project"
  environment   = "dev"
  name          = "my-user"
  user_policy   = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : "*"
      }
    ]
  })
}
```
