# ECS Service Module

## Description

This Terraform module creates an ECS Service with optional CloudWatch Alarms for monitoring CPU and Memory utilization. It includes configuration for load balancers, network settings, and capacity providers to ensure a scalable and reliable service.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.3.0 |
| aws       | >= 4.0   |
| external  | >= 2.2.0 |

## Providers

| Name | Version |
|------|---------|
| aws  | >= 4.0  |

## Inputs

| Name                                 | Description                                       | Type           | Default | Required |
|--------------------------------------|---------------------------------------------------|----------------|---------|:--------:|
| project                              | Project name                                      | `string`       | `-`     | yes      |
| environment                          | Environment name                                  | `string`       | `-`     | yes      |
| service                              | Service name (e.g., API)                          | `string`       | `-`     | yes      |
| cluster_name                         | Name of the ECS cluster                           | `string`       | `-`     | yes      |
| cluster_arn                          | ARN of the ECS cluster                            | `string`       | `-`     | yes      |
| task_definition                      | ARN of the ECS task definition                    | `string`       | `-`     | yes      |
| desired_count                        | Desired number of tasks                           | `number`       | `-`     | yes      |
| target_group_arn                     | ARN of the target group                           | `string`       | `-`     | yes      |
| container_name                       | Name of the container                             | `string`       | `-`     | yes      |
| container_port                       | Port on which the container is listening          | `number`       | `-`     | yes      |
| subnets                              | List of subnets                                   | `list(string)` | `-`     | yes      |
| security_group                       | List of security groups                           | `list(string)` | `-`     | yes      |
| assign_public_ip                     | Assign public IP address                          | `bool`         | `false` | no       |
| alarm_sns_arn                        | SNS topic ARN for alarms                          | `string`       | `""`    | no       |
| enable_cpu_alarm                     | Enable CPU utilization alarm                      | `bool`         | `false` | no       |
| enable_memory_alarm                  | Enable memory utilization alarm                   | `bool`         | `false` | no       |
| deployment_minimum_healthy_percent   | Minimum healthy percent during deployment         | `number`       | `100`   | no       |
| deployment_maximum_percent           | Maximum percent during deployment                 | `number`       | `200`   | no       |
| capacity_provider_fargate_base       | Base capacity for FARGATE capacity provider       | `number`       | `1`     | no       |
| capacity_provider_fargate_weight     | Weight for FARGATE capacity provider              | `number`       | `1`     | no       |
| capacity_provider_fargate_spot_weight| Weight for FARGATE_SPOT capacity provider         | `number`       | `0`     | no       |
| force_new_deployment                 | Force a new deployment of the service             | `bool`         | `false` | no       |

## Outputs

| Name         | Description                   |
|--------------|-------------------------------|
| service_name | The name of the ECS service   |

## Usage examples

### Basic Usage

```hcl
module "ecs_service" {
  source              = "github.com/opstimus/terraform-aws-ecs-service?ref=v<RELEASE>"

  project             = "example-project"
  environment         = "dev"
  service             = "api"
  cluster_name        = "example-cluster"
  cluster_arn         = "arn:aws:ecs:region:account-id:cluster/example-cluster"
  task_definition     = "arn:aws:ecs:region:account-id:task/example-task"
  desired_count       = 2
  target_group_arn    = "arn:aws:elasticloadbalancing:region:account-id:targetgroup/example-target"
  container_name      = "example-container"
  container_port      = 80
  subnets             = ["subnet-abc", "subnet-def"]
  security_group      = ["sg-12345"]
  assign_public_ip    = false

  enable_cpu_alarm    = true
  enable_memory_alarm = true
  alarm_sns_arn       = "arn:aws:sns:region:account-id:example-topic"
  force_new_deployment = false
}
```

## Notes

The ECS service name is created with the format `{project}-{environment}-{service}`.

This module requires the ARNs of a pre-existing ECS cluster and load balancer target group, as well as IDs for the task definition, subnets, and security groups to use.
