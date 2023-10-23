# AWS ECS Service

## Description

This Terraform module creates an Amazon Elastic Container Service (ECS) Fargate service with an associated load balancer and network configuration.

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
| service | The name of the service, e.g., "api". | `string` | - | yes |
| cluster_arn | The ARN of the ECS cluster. | `string` | - | yes |
| task_definition | The task definition to use. | `string` | - | yes |
| desired_count | The number of tasks to run. | `number` | - | yes |
| target_group_arn | The ARN of the target group for the load balancer. | `string` | - | yes |
| container_name | The name of the container to associate with the load balancer. | `string` | - | yes |
| container_port | The port on the container to associate with the load balancer. | `number` | - | yes |
| subnets | A list of subnet IDs for the network configuration. | `list(string)` | - | yes |
| security_group | A list of security group IDs for the network configuration. | `list(string)` | - | yes |
| assign_public_ip | Whether to assign a public IP to tasks. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| service_name | The name of the created ECS service. |

## Example Usage

```hcl
module "ecs_service" {
  source            = "s3::https://s3.amazonaws.com/ot-turbo-artifacts/tf/modules/aws/latest/ecs-service.zip"

  project           = "my_project"
  environment       = "my_environment"
  service           = "my_service"
  cluster_arn       = "arn:aws:ecs:region:account-id:cluster/cluster-name"
  task_definition   = "task-definition-id"
  desired_count     = 3
  target_group_arn  = "arn:aws:elasticloadbalancing:region:account-id:targetgroup/target-group-name/hash"
  container_name    = "my_container_name"
  container_port    = 80
  subnets           = ["subnet-id1", "subnet-id2"]
  security_group    = ["sg-id1", "sg-id2"]
  assign_public_ip  = false
}
```

## Notes

The ECS service name is created with the format `{project}-{environment}-{service}`.

This module requires the ARNs of a pre-existing ECS cluster and load balancer target group, as well as IDs for the task definition, subnets, and security groups to use.
