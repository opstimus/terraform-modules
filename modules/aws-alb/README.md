# AWS Application Load Balancer (ALB)

## Description

This Terraform module creates an Application Load Balancer (ALB), an associated security group and ALB listeners for HTTP and HTTPS protocols.

It also stores the ARN of the HTTPS listener in an SSM parameter.

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
| environment | The environment name. | `string` | - | yes |
| vpc_id | The VPC ID where the ALB will be created. | `string` | - | yes |
| subnet_ids | The IDs of the subnets where the ALB will be created. | `list(string)` | - | yes |
| internal | Determines whether to create an internal or public facing load balancer. | `bool` | `false` | no |
| certificate_arn | The ARN of the ACM certificate to associate with the HTTPS listener. | `string` | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| dns_name | The DNS name of the created Application Load Balancer. |

## Example Usage

```hcl
module "application_load_balancer" {
  source          = "s3::https://s3.amazonaws.com/ot-turbo-artifacts/tf/modules/aws/dev/alb.zip"

  project         = "my_project"
  environment     = "my_environment"
  vpc_id          = "vpc-0example0"
  subnet_ids      = ["subnet-0example1", "subnet-0example2"]
  internal        = false
  certificate_arn = "arn:aws:acm:region:account:certificate/example"
}
```
