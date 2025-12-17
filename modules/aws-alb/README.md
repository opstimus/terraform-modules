# ALB with Security Group Module

## Description

This Terraform module creates an Application Load Balancer (ALB) along with a security group in AWS. It also configures HTTP to HTTPS redirection, default SSL termination on the ALB using an ACM certificate, and outputs the DNS name of the ALB. Additionally, it stores the HTTPS listener ARN in AWS Systems Manager (SSM) Parameter Store.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.3.0 |
| aws       | >= 4.0   |
| external  | >= 2.2.0 |
| random    | >= 3.4.0 |

## Providers

| Name | Version  |
|------|----------|
| aws  | >= 4.0   |
| external | >= 2.2.0 |
| random   | >= 3.4.0 |

## Inputs

| Name            | Description                             | Type          | Default | Required |
|-----------------|-----------------------------------------|---------------|---------|:--------:|
| project         | Project name                            | `string`      | -       |   yes    |
| environment     | Environment name                        | `string`      | -       |   yes    |
| vpc_id          | The VPC ID to attach the ALB to         | `string`      | -       |   yes    |
| subnet_ids      | A list of subnet IDs for the ALB        | `list(string)`| -       |   yes    |
| internal        | Whether to create an internal ALB       | `bool`        | -       |   yes    |
| certificate_arn | ACM certificate ARN for HTTPS           | `string`      | -       |   yes    |
| idle_timeout    | Idle timeout in seconds (up to 4000)    | `number`      | 60      |    no    |
| tags            | tags                                    | `map(string)` | -       |    no    |

## Outputs

| Name     | Description         |
|----------|---------------------|
| dns_name | The DNS name of the ALB |

## Usage examples

### Basic Usage Example

```hcl
module "alb" {
  source          = "https://github.com/opstimus/terraform-aws-alb?ref=v<RELEASE>"
  project         = "my-project"
  environment     = "production"
  vpc_id          = "vpc-12345"
  subnet_ids      = ["subnet-12345", "subnet-67890"]
  internal        = false
  certificate_arn = "arn:aws:acm:region:account:certificate/certificate-id"
  idle_timeout    = 60
  tags = {
    Project     = <project-name>
    Environment = <environment-name>
  }
}
```