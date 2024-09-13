# CloudWatch Log Group Module

## Description

This Terraform module creates an AWS CloudWatch Log Group with a customizable name and retention policy. The log group name is structured using a prefix, project name, environment, and a specific group name. The retention period for logs is also configurable.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.3.0 |
| aws       | >= 4.0   |

## Providers

| Name | Version  |
|------|----------|
| aws  | >= 4.0   |

## Inputs

| Name             | Description                                  | Type      | Default | Required |
|------------------|----------------------------------------------|-----------|---------|:--------:|
| project          | Project name                                 | `string`  | -       |   yes    |
| environment      | Environment name                             | `string`  | -       |   yes    |
| name             | Log group name (e.g., api)                   | `string`  | -       |   yes    |
| prefix           | Service prefix (e.g., ecs)                   | `string`  | -       |   yes    |
| retention_in_days| Log retention period in days                 | `number`  | 180     |    no    |

## Outputs

| Name      | Description           |
|-----------|-----------------------|
| log_group | The name of the log group |

## Usage examples

### Basic Usage Example

```hcl
module "cloudwatch_log_group" {
  source            = "https://github.com/opstimus/terraform-aws-log-group?ref=v<RELEASE>"
  project           = "my-project"
  environment       = "production"
  name              = "api"
  prefix            = "ecs"
  retention_in_days = 365
}
```

## Notes

The name for the created Log Group follows the pattern `/{prefix}/{project}/{environment}/{name}`.
