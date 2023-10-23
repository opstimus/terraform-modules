# AWS ECS Task Definition

## Description

This Terraform module creates an AWS ECS Task Definition for a specific project, environment, and service.

It allows you to configure the task definition with the desired execution role, CPU and memory sizes, and container definitions.

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
| project | Project name | `string` | - | yes |
| environment | Environment name | `string` | - | yes |
| service | Service name (e.g., api) | `string` | - | yes |
| execution_role_arn | ARN of the execution role | `string` | - | yes |
| cpu | CPU size (in units) | `number` | `256` | no |
| memory | Memory size (in MiB) | `number` | `512` | no |
| container_definitions | Container definitions (as JSON-encoded string) | `string` | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| task_definition_arn | The ARN of the ECS Task Definition |

## Example Usage

```hcl
module "ecs_task_definition" {
  source                  = "s3::https://s3.amazonaws.com/ot-turbo-artifacts/tf/modules/aws/dev/task-definition.zip""
  project                 = "my_project"
  environment             = "my_environment"
  service                 = "api"
  execution_role_arn       = "arn:aws:iam::123456789012:role/execution-role"
  cpu                     = 256
  memory                  = 512
  container_definitions   = jsonencode([
    {
      "name": "my-container",
      "image": "my-image:latest",
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "ENV_VAR_1",
          "value": "value1"
        },
        {
          "name": "ENV_VAR_2",
          "value": "value2"
        }
      ]
    }
  ])
}
```

## Notes

The name for the created task definition family follows the pattern `{project}-{environment}-{service}`.
