# AWS ElastiCache Redis Module

## Description 

This Terraform module provisions an AWS ElastiCache Redis cluster, including associated security groups, parameter groups, subnet groups, and secrets. It supports optional authentication and encryption configurations.

Resources are named `<project>-<environment>` by default. Set the optional `name` input to provision multiple Redis instances per project/environment, named `<project>-<environment>-<name>`. Do not set `name` on existing deployments — changing the name forces the replication group and related resources to be destroyed and recreated.

## Requirements 

| Name | Version | 
|------|---------| 
| terraform | >= 1.3.0 | 
| aws | >= 6.0 | 
| random | >= 3.4.0 | 

## Providers 

| Name | Version | 
|------|---------| 
| aws | >= 6.0 | 
| random | >= 3.4.0 | 

## Inputs 

| Name                       | Description                          | Type    | Default | Required | 
|----------------------------|--------------------------------------|---------|---------|:--------:| 
| project                    | Project name                         | string  | -       | yes      | 
| environment                | Environment name                     | string  | -       | yes      | 
| name                       | Optional name segment included in resource names (e.g. `<project>-<environment>-<name>-redis`). Leave empty to keep the original `<project>-<environment>` naming — existing deployments must not set this, otherwise resources will be recreated | string  | ""      | no       | 
| parameter_group_family     | Parameter group family               | string  | -       | yes      | 
| parameter_group_parameters | List of parameter group parameters   | list    | []      | no       | 
| node_type                  | Node type for the ElastiCache cluster | string  | -       | yes      | 
| number_of_nodes            | Number of nodes in the cluster       | number  | 1       | no       | 
| engine_version             | Redis engine version                 | string  | -       | yes      | 
| vpc_id                     | VPC ID for the security group        | string  | -       | yes      | 
| vpc_cidr                   | VPC CIDR block                        | string  | -       | yes      | 
| private_subnet_ids         | List of private subnet IDs            | list    | -       | yes      | 
| log_group                  | CloudWatch log group                 | string  | -       | yes      | 
| enable_auth                | Enable authentication                | bool    | false   | no       | 
| enable_transit_encryption  | Enable transit encryption            | bool    | false   | no       | 
| enable_at_rest_encryption  | Enable at-rest encryption            | bool    | false   | no       |
| tags                       | tags                                 | `map(string)` | -       |    no    | 

## Outputs 

| Name                | Description                     | 
|---------------------|---------------------------------| 
| auth_token_secret   | The name of the Secrets Manager secret for authentication | 

## Usage examples 

### Example 1: Basic usage of the module

```hcl
module "elasticache_redis" {
  source                      = "github.com/opstimus/terraform-aws-elasticache-redis?ref=v<RELEASE>"
  project                     = "my-project"
  environment                 = "dev"
  parameter_group_family      = "redis6.x"
  node_type                   = "cache.t3.micro"
  number_of_nodes             = 1
  engine_version              = "6.x"
  vpc_id                      = "vpc-0abcd1234efgh5678"
  vpc_cidr                    = "172.16.0.0/16"
  private_subnet_ids          = ["subnet-0abcd1234efgh5678"]
  log_group                   = "my-log-group"
  enable_auth                 = true
  enable_transit_encryption   = true
  enable_at_rest_encryption   = true
  tags = {
    Project = <project-name>
    Environment = <environment-name>
  }
}
```

### Example 2: Named instance (multiple Redis clusters per project/environment)

```hcl
module "elasticache_redis_session" {
  source                      = "github.com/opstimus/terraform-aws-elasticache-redis?ref=v<RELEASE>"
  project                     = "my-project"
  environment                 = "dev"
  name                        = "session"
  parameter_group_family      = "redis6.x"
  node_type                   = "cache.t3.micro"
  number_of_nodes             = 1
  engine_version              = "6.x"
  vpc_id                      = "vpc-0abcd1234efgh5678"
  vpc_cidr                    = "172.16.0.0/16"
  private_subnet_ids          = ["subnet-0abcd1234efgh5678"]
  log_group                   = "my-log-group"
  enable_auth                 = true
  enable_transit_encryption   = true
  enable_at_rest_encryption   = true
}
```
