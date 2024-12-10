# ECR Repository Module

## Description

This Terraform module creates an Amazon ECR (Elastic Container Registry) repository and configures its policies. It supports setting image tag mutability, image scanning on push, and granting access to specified AWS accounts.

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

| Name                | Description                                          | Type   | Default | Required |
|---------------------|------------------------------------------------------|--------|---------|:--------:|
| project             | Project name                                         | string | -       |   yes    |
| service             | Name of the service (e.g., backend)                  | string | -       |   yes    |
| image_tag_mutability | Tag mutability for images (`true` for IMMUTABLE)    | bool   | true    |    no    |
| scan_on_push        | Enable image scanning on push                        | bool   | false   |    no    |
| account_ids         | List of AWS account IDs that can access the repository | list   | -       |   yes    |
| create_iam_user     | Enable to create IAM user for ECR tasks              | bool   | false   | no       |

## Outputs

| Name           | Description                           |
|----------------|---------------------------------------|
| repository_url | The URL of the created ECR repository  |

## Usage examples

### Basic ECR Repository Creation

This example demonstrates how to use the module to create an ECR repository with specific configurations.

```hcl
module "ecr_repository" {
  source                = "github.com/opstimus/terraform-aws-ecr?ref=v<RELEASE>"

  project               = "my-project"
  service               = "backend"
  image_tag_mutability  = true
  scan_on_push          = true
  account_ids           = ["123456789012", "210987654321"]
  create_iam_user       = false
}
```

## Notes

The name for the created repository follows the pattern `{project}-{service}`.
