# AWS ECS Auto Scaling Standard Module

## Description 

This Terraform module sets up AWS App Autoscaling targets and policies for ECS services. It manages scaling actions based on CPU and memory utilization metrics, allowing you to maintain optimal performance and resource usage.

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

| Name               | Description                           | Type    | Default | Required | 
|--------------------|---------------------------------------|---------|---------|:--------:| 
| cluster_name       | Name of the ECS cluster               | string  | -       | yes      | 
| service_name       | Name of the ECS service               | string  | -       | yes      | 
| min_capacity       | Minimum capacity for autoscaling      | number  | -       | yes      | 
| max_capacity       | Maximum capacity for autoscaling      | number  | -       | yes      | 
| cpu_target_value   | Target CPU utilization percentage     | number  | 60      | no       | 
| memory_target_value | Target memory utilization percentage  | number  | 60      | no       | 
| scale_in_cooldown  | Cooldown period for scale-in actions  | number  | 300     | no       | 
| scale_out_cooldown | Cooldown period for scale-out actions | number  | 60      | no       | 

## Outputs 

| Name                | Description                     | 
|---------------------|---------------------------------| 
| resource_id         | The resource ID of the autoscaling target | 
| scalable_dimension  | The scalable dimension of the autoscaling target | 
| service_namespace   | The service namespace of the autoscaling target | 

## Usage examples 

### Example 1: Basic usage of the module

```hcl
module "app_autoscaling" {
  source              = "github.com/opstimus/terraform-aws-ecs-autoscaling-standard?ref=v<RELEASE>"
  cluster_name        = "my-cluster"
  service_name        = "my-service"
  min_capacity        = 1
  max_capacity        = 10
  cpu_target_value    = 50
  memory_target_value = 50
  scale_in_cooldown   = 300
  scale_out_cooldown  = 60
}
```
