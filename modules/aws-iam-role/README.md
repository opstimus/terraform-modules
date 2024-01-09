# AWS IAM Role Module

## Description
This Terraform module creates an AWS IAM Role and an associated IAM Role Policy. It is designed for flexibility, allowing users to specify the project, environment, role name, assume role policy, and role policy.

## Requirements

| Name       | Version  |
|------------|----------|
| terraform  | >= 1.3.0 |
| aws        | >= 4.0   |

## Providers

| Name | Version |
|------|---------|
| aws  | ~> 4.0  |

## Inputs

| Name                | Description       | Type     | Default | Required |
|---------------------|-------------------|----------|---------|:--------:|
| project             | Project name      | `string` | -       | yes      |
| environment         | Environment name  | `string` | -       | yes      |
| name                | Role name         | `string` | -       | yes      |
| assume_role_policy  | Assume role policy| `string` | -       | yes      |
| role_policy         | Role policy       | `string` | -       | yes      |

## Outputs

| Name      | Description              |
|-----------|--------------------------|
| role_name | The name of the IAM role |
| role_arn  | The ARN of the IAM role  |

## Usage examples

### Basic Usage

```hcl
module "iam_role_example" {
  source = "github.com/opstimus/terraform-aws-iam-role?ref=vN.N.N"

  project            = "my-project"
  environment        = "production"
  name               = "my-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:*"
        ],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}
```

