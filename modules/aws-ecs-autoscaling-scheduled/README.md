# AWS ECS Auto Scaling Scheduled Action Module

## Description 

This Terraform module creates an AWS App Autoscaling scheduled action. It allows you to define scheduled scaling actions for AWS ECS services based on a specified schedule.

## Requirements 

| Name | Version | 
|------|---------| 
| terraform | >= 1.3.0 | 
| aws | >= 4.0 | 

## Providers 

| Name | Version | 
|------|---------| 
| aws | >= 4.0 | 

## Inputs 

| Name            | Description                   | Type   | Default | Required | 
|-----------------|-------------------------------|--------|---------|:--------:| 
| service_name    | Name of the service           | string | -       | yes      | 
| policy_name     | Name of the policy            | string | -       | yes      | 
| schedule        | Schedule for scaling action   | string | -       | yes      | 
| min_capacity    | Minimum capacity              | number | -       | yes      | 
| max_capacity    | Maximum capacity              | number | -       | yes      | 
| resource_id     | Resource ID for scaling       | string | -       | yes      | 

## Usage examples 

### Example 1: Basic usage of the module

```hcl
module "app_autoscaling_scheduled_action" {
  source           = "github.com/opstimus/terraform-aws-ecs-autoscaling-scheduled?ref=v<RELEASE>"
  service_name     = "my-service"
  policy_name      = "my-scaling-policy"
  schedule         = "cron(0 8 * * ? *)"
  min_capacity     = 1
  max_capacity     = 5
  resource_id      = "my-resource-id"
}
```
