# PostgreSQL Database and User Provisioning

## Description

This Terraform module creates a PostgreSQL database and user with appropriate privileges. It uses the PostgreSQL provider to manage database resources and stores credentials in AWS Secrets Manager.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | >= 6.0 |
| postgresql | >= 1.26 |
| random | >= 3.7 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 6.0 |
| postgresql | >= 1.26 |
| random | >= 3.7 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project | Project name | `string` | - | yes |
| environment | Environment name | `string` | - | yes |
| service_name | Service name | `string` | - | yes |
| database_name | Name of the PostgreSQL database to create | `string` | - | yes |
| database_user | Name of the PostgreSQL user/role to create | `string` | - | yes |
| master_username | Master database username (used as owner for default privileges) | `string` | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| database_name | Name of the created database |
| database_user | Name of the created user/role |
| user_credentials_secret_name | Name of the Secrets Manager secret storing the created database user credentials |
| user_credentials_secret_arn | ARN of the Secrets Manager secret storing the created database user credentials |

## Example Usage

```hcl
provider "postgresql" {
  host            = data.aws_rds_cluster.aurora.endpoint
  port            = 5432
  database        = data.aws_rds_cluster.aurora.database_name
  username        = local.master_credentials.username
  password        = local.master_credentials.password
  sslmode         = "require"
  connect_timeout = 15
}

module "postgresql_app" {
  source = "github.com/opstimus/terraform-postgresql?ref=v1.0.0"

  project         = local.project
  environment     = var.environment
  service_name    = "app"
  database_name   = "app_db"
  database_user   = "app_user"
  master_username = local.aurora_credentials.username
}
```

## Notes

- The module requires a configured PostgreSQL provider with access to the RDS cluster
- The master username is used as the owner for default privileges on tables and sequences
- The created user credentials are stored in Secrets Manager as JSON with `username` and `password` fields
- The module grants ALL privileges on the database, schema, tables, and sequences to the created user
