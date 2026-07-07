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
| transit_encryption_mode    | Transit encryption mode (`preferred` or `required`), applies only when transit encryption is enabled. Setting `required` while transit encryption is disabled is a plan-time error. `preferred` requires Redis engine 7.0.5+ | string  | "preferred" | no       | 
| enable_at_rest_encryption  | Enable at-rest encryption            | bool    | false   | no       |
| tags                       | tags                                 | `map(string)` | -       |    no    | 

## Outputs 

| Name                | Description                     | 
|---------------------|---------------------------------| 
| auth_token_secret   | The name of the Secrets Manager secret for authentication | 

## Encryption behavior

The auth and transit encryption inputs interact: `enable_auth = true` always enables transit encryption (an auth token requires TLS), and `transit_encryption_mode` only applies when transit encryption is enabled. `at_rest_encryption_enabled` is independent of all of these.

| `enable_auth` | `enable_transit_encryption` | `transit_encryption_mode` | Result |
|:---:|:---:|:---:|---|
| `true` | any | `preferred` (default) | Auth token created, TLS enabled, plaintext still allowed |
| `true` | any | `required` | Auth token created, TLS enforced — plaintext connections refused |
| `false` | `true` | `preferred` (default) | No auth, TLS enabled, plaintext still allowed |
| `false` | `true` | `required` | No auth, TLS enforced — plaintext connections refused |
| `false` | `false` | `preferred` (default) | No auth, no TLS — mode is ignored |
| `false` | `false` | `required` | ❌ Plan-time error |

## Usage examples 

### Example 1: Basic usage of the module

```hcl
module "elasticache_redis" {
  source                      = "github.com/opstimus/terraform-aws-elasticache-redis?ref=v<RELEASE>"
  project                     = "my-project"
  environment                 = "dev"
  parameter_group_family      = "redis7"
  node_type                   = "cache.t3.micro"
  number_of_nodes             = 1
  engine_version              = "7.1"
  vpc_id                      = "vpc-0abcd1234efgh5678"
  vpc_cidr                    = "172.16.0.0/16"
  private_subnet_ids          = ["subnet-0abcd1234efgh5678"]
  log_group                   = "my-log-group"
  enable_auth                 = true
  enable_transit_encryption   = true
  transit_encryption_mode     = "preferred"
  enable_at_rest_encryption   = true
  tags = {
    Project     = "my-project"
    Environment = "dev"
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
  parameter_group_family      = "redis7"
  node_type                   = "cache.t3.micro"
  number_of_nodes             = 1
  engine_version              = "7.1"
  vpc_id                      = "vpc-0abcd1234efgh5678"
  vpc_cidr                    = "172.16.0.0/16"
  private_subnet_ids          = ["subnet-0abcd1234efgh5678"]
  log_group                   = "my-log-group"
  enable_auth                 = true
  enable_transit_encryption   = true
  transit_encryption_mode     = "preferred"
  enable_at_rest_encryption   = true
}
```

### Example 3: Authentication enabled

With `enable_auth = true`, an auth token is generated and stored in Secrets Manager, and transit encryption is always enabled (regardless of `enable_transit_encryption`). The default `transit_encryption_mode` of `preferred` still allows plaintext connections — set it to `required` to enforce encryption for all clients.

```hcl
module "elasticache_redis" {
  source                      = "github.com/opstimus/terraform-aws-elasticache-redis?ref=v<RELEASE>"
  project                     = "my-project"
  environment                 = "dev"
  parameter_group_family      = "redis7"
  node_type                   = "cache.t3.micro"
  number_of_nodes             = 1
  engine_version              = "7.1"
  vpc_id                      = "vpc-0abcd1234efgh5678"
  vpc_cidr                    = "172.16.0.0/16"
  private_subnet_ids          = ["subnet-0abcd1234efgh5678"]
  log_group                   = "my-log-group"
  enable_auth                 = true
  transit_encryption_mode     = "required"
  enable_at_rest_encryption   = true
}
```

### Example 4: No authentication, transit encryption only

With `enable_auth = false`, no auth token or secret is created. Transit encryption can still be enabled via `enable_transit_encryption`, and `transit_encryption_mode` applies to it. If both flags are false, transit encryption is off and `transit_encryption_mode` is ignored.

```hcl
module "elasticache_redis" {
  source                      = "github.com/opstimus/terraform-aws-elasticache-redis?ref=v<RELEASE>"
  project                     = "my-project"
  environment                 = "dev"
  parameter_group_family      = "redis7"
  node_type                   = "cache.t3.micro"
  number_of_nodes             = 1
  engine_version              = "7.1"
  vpc_id                      = "vpc-0abcd1234efgh5678"
  vpc_cidr                    = "172.16.0.0/16"
  private_subnet_ids          = ["subnet-0abcd1234efgh5678"]
  log_group                   = "my-log-group"
  enable_auth                 = false
  enable_transit_encryption   = true
  transit_encryption_mode     = "preferred"
  enable_at_rest_encryption   = true
}
```
