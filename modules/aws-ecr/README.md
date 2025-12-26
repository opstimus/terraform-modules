# ECR Repository Module

## Description

This Terraform module creates an Amazon ECR (Elastic Container Registry) repository and configures its policies. It supports setting image tag mutability, image scanning on push, and granting access to specified AWS accounts. Optionally creates an IAM managed policy that can be attached to an IAM user or IAM role for GitHub Actions OIDC authentication.

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
| create_iam_user     | Enable to create IAM user for ECR tasks              | bool   | false   |    no    |
| create_iam_role     | Enable to create IAM role for GitHub Actions OIDC    | bool   | false   |    no    |
| github_oidc_subjects | List of GitHub OIDC subjects (e.g., `repo:owner/repo:ref:refs/heads/main`) | list(string) | [] |    no    |

## Outputs

| Name           | Description                           |
|----------------|---------------------------------------|
| repository_url | The URL of the created ECR repository  |

## Usage examples

### Basic ECR Repository Creation

```hcl
module "ecr_repository" {
  source                = "github.com/opstimus/terraform-aws-ecr?ref=v<RELEASE>"

  project               = "my-project"
  service               = "backend"
  image_tag_mutability  = true
  scan_on_push          = true
  account_ids           = ["123456789012", "210987654321"]
  create_iam_user       = false
  create_iam_role       = false
}
```

### With GitHub Actions IAM Role

```hcl
module "ecr_repository" {
  source                = "github.com/opstimus/terraform-aws-ecr?ref=v<RELEASE>"

  project               = "my-project"
  service               = "backend"
  account_ids           = ["123456789012"]
  create_iam_role       = true
  github_oidc_subjects  = [
    "repo:owner/repo:ref:refs/heads/main",
    "repo:owner/repo:pull_request"
  ]
}
```

## Notes

The name for the created repository follows the pattern `{project}-{service}`.
