# ECS Cluster Module

## Description

This Terraform module sets up an ECS cluster with necessary IAM roles, security groups, and CloudWatch monitoring. It creates a new ECS cluster with Fargate and Fargate Spot capacity providers, configures a task execution IAM role with appropriate policies, and sets up security groups for the cluster.

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.3.0  |
| aws       | >= 6.0    |

## Providers

| Name | Version |
|------|---------|
| aws  | >= 6.0  |

## Inputs

| Name                       | Description                                  | Type         | Default | Required |
|----------------------------|----------------------------------------------|--------------|---------|:--------:|
| project                    | Project name                                 | string       | -       |   yes    |
| environment                | Environment name                             | string       | -       |   yes    |
| name                       | Optional name suffix appended to resource names | string    | `""`    |    no    |
| vpc_id                     | The ID of the VPC                            | string       | -       |   yes    |
| vpc_cidr                   | The CIDR block of the VPC                    | string       | -       |   yes    |
| container_insights         | Enable container insights for the cluster    | bool         | false   |    no    |
| tags                       | tags                                         | `map(string)` | -      |    no    |

## Outputs

| Name                      | Description                            |
|---------------------------|----------------------------------------|
| cluster_name              | The name of the ECS cluster            |
| cluster_arn               | The ARN of the ECS cluster             |
| security_group_id         | The ID of the security group           |
| task_execution_role_arn   | The ARN of the task execution role     |

## Usage examples

### Basic ECS Cluster Setup

This example shows how to use the ECS cluster module to create an ECS cluster with Fargate and Fargate Spot capacity providers.

```hcl
module "ecs_cluster" {
  source             = "github.com/opstimus/terraform-aws-ecs-cluster?ref=v<RELEASE>"
  project            = "my-project"
  environment        = "dev"
  vpc_id             = "vpc-0bb1c79de3EXAMPLE"
  vpc_cidr           = "10.0.0.0/16"
  container_insights = true
  tags = {
    Project     = <project-name>
    Environment = <environment-name>
  }
}
```

### With Optional Name Suffix

When `name` is provided, resources are named `{project}-{environment}-{name}-resource-type` instead of the default `{project}-{environment}-resource-type`.

```hcl
module "ecs_cluster" {
  source             = "github.com/opstimus/terraform-aws-ecs-cluster?ref=v<RELEASE>"
  project            = "my-project"
  environment        = "dev"
  name               = "api"
  vpc_id             = "vpc-0bb1c79de3EXAMPLE"
  vpc_cidr           = "10.0.0.0/16"
  container_insights = true
  tags = {
    Project     = <project-name>
    Environment = <environment-name>
  }
}
```

## Notes

Resource names follow the pattern `{project}-{environment}-resource-type` by default. When the optional `name` variable is set, the pattern becomes `{project}-{environment}-{name}-resource-type`.
