# Load Balancer Target Group Module

## Description

This Terraform module provisions an AWS Load Balancer target group along with listener rules for routing traffic to the target group based on host headers. It includes health checks, listener priorities, and supports HTTP protocol with IP-based targets.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.3.0 |
| aws       | >= 4.0   |
| external | >= 2.2.0 |

## Providers

| Name | Version  |
|------|----------|
| aws  | >= 4.0   |
| external | >= 2.2.0 |

## Inputs

| Name                   | Description                              | Type        | Default | Required |
|------------------------|------------------------------------------|-------------|---------|:--------:|
| project                | Project name                             | `string`    | -       |   yes    |
| environment            | Environment name                         | `string`    | -       |   yes    |
| service                | Service name (i.e. api)                  | `string`    | -       |   yes    |
| port                   | Port number                              | `string`    | -       |   yes    |
| vpc_id                 | VPC ID                                   | `string`    | -       |   yes    |
| application_status_code| Application health check status code      | `number`    | 200     |    no    |
| listener_arn           | Listener ARN from ALB                    | `string`    | -       |   yes    |
| priority               | Listener rule priority number            | `number`    | 100     |    no    |
| host_headers           | Service URLs (i.e. api.domain.com)        | `list(any)` | -       |   yes    |

## Outputs

| Name             | Description            |
|------------------|------------------------|
| target_group_arn | The ARN of the target group |

## Usage examples

### Basic Usage Example

```hcl
module "lb_target_group" {
  source                  = "https://github.com/opstimus/terraform-aws-target-group?ref=v<RELEASE>"
  project                 = "my-project"
  environment             = "production"
  service                 = "api"
  port                    = "80"
  vpc_id                  = "vpc-12345678"
  application_status_code = 200
  listener_arn            = "arn:aws:elasticloadbalancing:region:account-id:listener/app/alb-name/arn-id"
  priority                = 10
  host_headers            = ["api.domain.com"]
}
```