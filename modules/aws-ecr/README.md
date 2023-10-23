# AWS ECR Repository

## Description

This Terraform module creates an ECR repository and its corresponding IAM policy for specific AWS account IDs to access this repository.

The module allows configuring the repository to make image tags immutable and to scan images on push.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project | The project name. | `string` | - | yes |
| service | Name of the service, i.e backend. | `string` | - | yes |
| image_tag_mutability | Whether image tags are mutable or not. If set to `true`, tags are immutable. | `bool` | - | yes |
| scan_on_push | If `true`, images will be scanned on push. | `bool` | `false` | no |
| account_ids | Accounts that can pull images from the repository. | `list(any)` | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| repository_url | The URL of the created ECR repository. |

## Example Usage

```hcl
module "ecr_repository" {
  source               = "s3::https://s3.amazonaws.com/ot-turbo-artifacts/tf/modules/aws/dev/ecr.zip"

  project              = "my_project"
  service              = "my_service"
  image_tag_mutability = true
  scan_on_push         = true
  account_ids          = ["123456789012", "234567890123"]
}
```

## Notes

The name for the created repository follows the pattern `{project}-{service}`.
