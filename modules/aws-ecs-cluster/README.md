# AWS ECS Cluster

## Description

This Terraform module creates an Amazon Elastic Container Service (ECS) cluster with a dedicated IAM task execution role, security group, and relevant SSM parameters.

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
| project | The name of the project. | `string` | - | yes |
| environment | The name of the environment. | `string` | - | yes |
| vpc_id | The ID of the VPC where the resources will be created. | `string` | - | yes |
| vpc_cidr | The CIDR block for the VPC. | `string` | - | yes |
| container_insights | Whether to enable container insights for the ECS cluster. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_name | The name of the created ECS cluster. |
| cluster_arn | The ARN of the created ECS cluster. |
| security_group_id | The ID of the created security group. |
| task_execution_role_arn | The ARN of the created task execution IAM role. |

## Example Usage

```hcl
module "ecs_cluster" {
  source            = "s3::https://s3.amazonaws.com/ot-turbo-artifacts/tf/modules/aws/latest/ecs-cluster.zip"

  project           = "my_project"
  environment       = "my_environment"
  vpc_id            = "vpc-id"
  vpc_cidr          = "10.0.0.0/16"
  container_insights = true
}
```

## Notes

The names for the created resources follow the pattern `{project}-{environment}-resource-type`.
