# IAM Role Module

## Description

This Terraform module creates an AWS IAM Role with an associated role policy. The module allows defining the assume role policy and role policy as inputs and outputs the IAM role's name and ARN.

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.3.0  |
| aws       | >= 4.0    |

## Providers

| Name | Version |
|------|---------|
| aws  | >= 4.0  |

## Inputs

| Name              | Description              | Type   | Default | Required |
|-------------------|--------------------------|--------|---------|:--------:|
| project           | Project name             | string | -       |   yes    |
| environment       | Environment name         | string | -       |   yes    |
| name              | Role name                | string | -       |   yes    |
| assume_role_policy| IAM assume role policy   | string | -       |   yes    |
| role_policy       | IAM role policy          | string | -       |   yes    |

## Outputs

| Name      | Description           |
|-----------|-----------------------|
| role_name | The name of the IAM role |
| role_arn  | The ARN of the IAM role  |

## Usage examples

### Basic IAM Role Setup

This example demonstrates how to use the IAM Role module to create a role with a specified assume role policy and role policy.

```hcl
module "iam_role" {
  source              = "github.com/opstimus/terraform-aws-iam-role?ref=v<RELEASE>"

  project             = "my-project"
  environment         = "dev"
  name                = "my-role"
  assume_role_policy  = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  role_policy = jsonencode({
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
