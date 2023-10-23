# AWS CloudWatch Log Group

## Description

This Terraform module creates a CloudWatch Log Group with a customizable prefix, project name, environment, and log group name.

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
| prefix | The service prefix (i.e. 'ecs'). | `string` | - | yes |
| project | The name of the project. | `string` | - | yes |
| environment | The name of the environment. | `string` | - | yes |
| name | The name of the log group (i.e. 'api'). | `string` | - | yes |
| retention_in_days | The number of days to retain log events. | `number` | `180` | no |

## Outputs

| Name | Description |
|------|-------------|
| log_group | The name of the created CloudWatch Log Group. |

## Example Usage

```hcl
module "cloudwatch_log_group" {
  source            = "s3::https://s3.amazonaws.com/ot-turbo-artifacts/tf/modules/aws/dev/log-group.zip"

  prefix            = "ecs"
  project           = "my_project"
  environment       = "my_environment"
  name              = "api"
  retention_in_days = 180
}
```

## Notes

The name for the created Log Group follows the pattern `/{prefix}/{project}/{environment}/{name}`.
