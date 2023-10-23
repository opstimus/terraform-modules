# AWS Load Balancer Target Group and Listener Rule

## Description

This Terraform module creates an Amazon Load Balancer (ALB) Target Group and Listener Rule, configured with a list of host headers.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | ~> 4.0 |
| external | >= 2.2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 4.0 |
| external | >= 2.2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project | Project name | `string` | - | yes |
| environment | Environment name | `string` | - | yes |
| service | Service name (e.g., api) | `string` | - | yes |
| port | Port number | `string` | - | yes |
| vpc_id | VPC ID | `string` | - | yes |
| listener_arn | Listener ARN from ALB | `string` | - | yes |
| priority | Listener rule priority number | `number` | `100` | no |
| host_headers | Service URLs (e.g., api.domain.com) | `list(any)` | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| target_group_arn | The ARN of the Target Group |

## Example Usage

```hcl
module "api_target_group" {
  source        = "s3::https://s3.amazonaws.com/ot-turbo-artifacts/tf/modules/aws/dev/target-group.zip"

  project       = "my_project"
  environment   = "my_environment"
  service       = "api"
  port          = "8080"
  vpc_id        = "vpc-abc123"
  listener_arn  = "arn:aws:elasticloadbalancing:us-west-2:123456789012:listener/app/my-load-balancer/50dc6c495c0c9188/f2f7dc8efc522ab2"
  priority      = 100
  host_headers  = ["api.mydomain.com"]
}
```
