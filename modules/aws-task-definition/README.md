# ECS Task Definition Module

## Description

This Terraform module creates an Amazon ECS (Elastic Container Service) task definition and optionally an IAM role with a policy for the task. It supports configuration for CPU, memory, and container definitions, and integrates with Fargate for serverless container management.

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.3.0  |
| aws       | >= 4.0    |
| external | >= 2.2.0 |

## Providers

| Name | Version |
|------|---------|
| aws  | >= 4.0  |
| external | >= 2.2.0 |

## Inputs

| Name                   | Description                             | Type   | Default | Required |
|------------------------|-----------------------------------------|--------|---------|:--------:|
| project                | Project name                           | string | -       |   yes    |
| environment            | Environment name                       | string | -       |   yes    |
| service                | Service name (e.g., api)               | string | -       |   yes    |
| execution_role_arn     | ARN of the execution role              | string | -       |   yes    |
| cpu                    | CPU size (e.g., 256)                   | number | 256     |    no    |
| memory                 | Memory size (e.g., 512)                | number | 512     |    no    |
| container_definitions  | JSON formatted container definitions   | string | -       |   yes    |
| task_role_policy       | Inline policy for the task role        | string | ""      |    no    |

## Outputs

| Name                  | Description                        |
|-----------------------|------------------------------------|
| task_definition_arn   | The ARN of the ECS task definition  |

## Usage examples

### Basic ECS Task Definition Creation

This example demonstrates how to use the module to create an ECS task definition and an IAM role if needed.

```hcl
module "ecs_task_definition" {
  source                = "github.com/opstimus/terraform-aws-task-definition?ref=v<RELEASE>"
  
  project               = "my-project"
  environment           = "production"
  service               = "api"
  execution_role_arn    = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
  cpu                   = 256
  memory                = 512
  container_definitions = jsonencode([
    {
      name      = "my-container"
      image     = "my-image:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
  task_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "s3:ListBucket",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}
```

## Notes

The name for the created task definition family follows the pattern `{project}-{environment}-{service}`.
