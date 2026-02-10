# SNS Topic Module

## Description

This Terraform module provisions an AWS SNS (Simple Notification Service) topic. It supports both FIFO (First-In-First-Out) and standard SNS topics.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.3.0 |
| aws       | >= 6.0   |

## Providers

| Name | Version  |
|------|----------|
| aws  | >= 6.0   |

## Inputs

| Name        | Description            | Type     | Default     | Required |
|-------------|------------------------|----------|-------------|:--------:|
| project     | Project name            | `string` | -           |   yes    |
| environment | Environment name        | `string` | -           |   yes    |
| name        | Topic name              | `string` | -           |   yes    |
| sns_type    | SNS topic type (fifo/standard) | `string` | "standard" |   no     |
| tags        | tags                           | `map(string)` | -       |    no    |

## Outputs

| Name    | Description          |
|---------|----------------------|
| sns_arn | The ARN of the SNS topic |

## Usage examples

### Basic Usage Example

```hcl
module "sns_topic" {
  source      = "https://github.com/opstimus/terraform-aws-sns?ref=v<RELEASE>"
  project     = "my-project"
  environment = "production"
  name        = "alerts"
  sns_type    = "fifo"
  tags = {
    Project = <project-name>
    Environment = <environment-name>
  }
}
```
