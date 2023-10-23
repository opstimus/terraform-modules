# AWS ECS Auto Scaling Scheduled Action

## Description

This Terraform module creates an AWS Application Auto Scaling Scheduled Action for an ECS service.

This is useful when you need to schedule automatic scaling of your ECS services based on time or a cron schedule.

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
| service_name | The name of the ECS service. | `string` | - | yes |
| policy_name | The name of the scaling policy. | `string` | - | yes |
| schedule | The schedule or cron expression. Example: `"cron(0 8 * * ? *)"` | `string` | - | yes |
| min_capacity | The minimum capacity to scale down to. | `number` | - | yes |
| max_capacity | The maximum capacity to scale up to. | `number` | - | yes |
| resource_id | The resource ID of the scalable target. | `string` | - | yes |

## Example Usage

```hcl
module "appautoscaling_scheduled_action" {
  source       = "s3::https://s3.amazonaws.com/ot-turbo-artifacts/tf/modules/aws/dev/ecs-autoscaling-scheduled.zip"

  service_name = "my_service"
  policy_name  = "my_policy"
  schedule     = "cron(0 8 * * ? *)"
  min_capacity = 1
  max_capacity = 10
  resource_id  = "service/default/example"
}
```
