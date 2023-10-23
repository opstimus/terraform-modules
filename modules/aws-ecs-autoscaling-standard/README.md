# AWS ECS Auto Scaling Standard

## Description

This Terraform module creates an AWS Application Auto Scaling Target for an ECS service, and applies scaling policies for both CPU and memory utilization based on average value.

This is useful when you need to automatically scale your ECS services based on CPU or memory usage.

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
| cluster_name | The name of the ECS cluster. | `string` | - | yes |
| service_name | The name of the ECS service. | `string` | - | yes |
| min_capacity | The minimum capacity to scale down to. | `number` | - | yes |
| max_capacity | The maximum capacity to scale up to. | `number` | - | yes |
| cpu_target_value | The target average CPU utilization. | `number` | 60 | no |
| memory_target_value | The target average memory utilization. | `number` | 60 | no |
| scale_in_cooldown | The cooldown period in seconds after a scale in event. | `number` | 300 | no |
| scale_out_cooldown | The cooldown period in seconds after a scale out event. | `number` | 60 | no |

## Outputs

| Name | Description |
|------|-------------|
| resource_id | The resource ID of the scalable target. |
| scalable_dimension | The scalable dimension associated with the scalable target. |
| service_namespace | The service namespace associated with the scalable target. |

## Example Usage

```hcl
module "appautoscaling_target" {
  source            = "s3::https://s3.amazonaws.com/ot-turbo-artifacts/tf/modules/aws/dev/ecs-autoscaling-standard.zip"

  cluster_name      = "my_cluster"
  service_name      = "my_service"
  min_capacity      = 1
  max_capacity      = 10
  cpu_target_value  = 70
  memory_target_value = 80
  scale_in_cooldown  = 300
  scale_out_cooldown = 60
}
```
