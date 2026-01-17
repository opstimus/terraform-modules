# Aurora RDS Cluster Module

## Description

This module sets up an Aurora RDS Cluster along with necessary resources like security groups, subnet groups, parameter groups, and alarms. It supports both MySQL and PostgreSQL Aurora engines, enables encryption, manages secret credentials, and optionally configures RDS Proxy.

## Requirements

| Name       | Version   |
|------------|-----------|
| terraform  | >= 1.3.0  |
| aws        | >= 4.0    |
| random     | >= 3.4.0  |
| time       | >= 0.9    |
| external   | >= 2.2.0  |

## Providers

| Name  | Version   |
|-------|-----------|
| aws   | >= 4.0    |
| random| >= 3.4.0  |
| time  | >= 0.9    |

## Inputs

| Name                         | Description                                              | Type              | Default              | Required |
|------------------------------|----------------------------------------------------------|-------------------|----------------------|:--------:|
| project                      | Project name                                             | `string`          | -                    | yes      |
| environment                  | Environment name                                         | `string`          | -                    | yes      |
| name                         | Cluster identifier name                                  | `string`           | -                   | no       |
| parameter_group_family        | The DB parameter group family                            | `string`          | -                    | yes      |
| instance_count               | Number of RDS instances in the cluster                   | `number`          | 1                    | no       |
| engine_mode                  | Aurora engine mode (provisioned, serverless, etc.)        | `string`          | "provisioned"        | no       |
| engine                       | Aurora engine type (aurora-mysql, aurora-postgresql)      | `string`          | -                    | yes      |
| engine_version               | Version of the Aurora engine                             | `string`          | -                    | yes      |
| db_name                      | Name of the default database                             | `string`          | -                    | yes      |
| master_username              | Master username for the database                         | `string`          | "opadmin"              | no       |
| skip_final_snapshot          | Skip final snapshot on cluster deletion                  | `bool`            | true                 | no       |
| snapshot_identifier          | Identifier of the snapshot to restore from               | `string`          | ""                   | no       |
| deletion_protection          | Enable deletion protection for the cluster               | `bool`            | false                | no       |
| enabled_cloudwatch_logs_exports | List of logs to export to CloudWatch                  | `list(string)`    | -                    | no       |
| backup_retention_period      | Backup retention period (in days)                        | `number`          | 30                   | no       |
| storage_encrypted            | Enable encryption for the RDS cluster                    | `bool`            | true                 | no       |
| kms_key_id                   | KMS Key ID for encryption                                | `string`          | -                    | no       |
| network_type                 | Type of network (IPV4, DUAL)                             | `string`          | "IPV4"               | no       |
| performance_insights_enabled | Enable performance insights                              | `bool`            | false                | no       |
| instancetype                 | Instance type for RDS instances                          | `string`          | "db.t3.medium"       | no       |
| vpc_id                       | VPC ID                                                   | `string`          | -                    | yes      |
| private_subnet_ids           | List of private subnet IDs                               | `list(string)`    | -                    | yes      |
| vpc_cidr                     | CIDR block of the VPC                                    | `string`          | -                    | yes      |
| parameter_group_parameters   | Parameters for the parameter group                       | `list(object)`    | []                   | no       |
| alarm_sns_arn                | SNS Topic ARN for alarms                                 | `string`          | ""                   | no       |
| enable_cpu_alarm             | Enable alarms for high CPU utilization                   | `bool`            | false                | no       |
| enable_rds_proxy             | Enable RDS Proxy                                         | `bool`            | false                | no       |
| debug_logging                | Enable debug logging                                     | `bool`            | false                | no       |
| engine_family                | Engine family for RDS Proxy                              | `string`          | null                 | no       |
| require_tls                  | Require TLS for RDS Proxy                                | `bool`            | false                | no       |
| port                         | Port for the RDS instance                                | `number`          | 0                    | no       |
| connection_borrow_timeout    | Connection borrow timeout for RDS Proxy                  | `number`          | 120                  | no       |
| init_query                   | SQL query to initialize each connection                  | `string`          | null                 | no       |
| max_connections_percent      | Maximum percentage of connections to allow               | `number`          | 80                   | no       |
| max_idle_connections_percent | Maximum percentage of idle connections                   | `number`          | 50                   | no       |
| enable_autoscaling           | Enable autoscaling. `instance_count` should be 2 or more | `bool`            | false                | no       |
| max_capacity                 | Auto Scaling maximum capacity                            | `number`          | `2`                  | no       |
| cpu_target_value             | CPU target value for autoscaling                         | `number`          | `80`                 | no       |
| scale_out_cooldown           | Cooldown period in seconds after a scale out activity    | `number`          | `300`                | no       |
| scale_in_cooldown            | Cooldown period in seconds after a scale in activity     | `number`          | `900`                | no       |
| enable_serverless_v2         | Enable Aurora Serverless v2 scaling                      | `bool`            | `false`              | no       |
| serverless_v2_min_capacity   | Minimum Aurora Capacity Units (ACU) for Serverless v2    | `number`          | `0.5`                | no       |
| serverless_v2_max_capacity   | Maximum Aurora Capacity Units (ACU) for Serverless v2    | `number`          | `4`                  | no       |

## Outputs

| Name              | Description                                   |
|-------------------|-----------------------------------------------|
| db_password_secret| Name of the Secrets Manager secret for DB password |


## Usage examples

### Example 1

```hcl
module "aurora_rds_cluster" {
  source = "https://github.com/opstimus/terraform-aws-aurora?ref=v<RELEASE>"

  project                       = "my-project"
  environment                   = "production"
  vpc_id                        = "vpc-123456"
  private_subnet_ids            = ["subnet-123", "subnet-456"]
  vpc_cidr                      = "10.0.0.0/16"
  engine                        = "aurora-mysql"
  engine_version                = "5.7.mysql_aurora.2.10.0"
  db_name                       = "mydb"
  master_username               = "admin"
  parameter_group_family        = "aurora-mysql5.7"
  performance_insights_enabled  = true
  storage_encrypted             = true
  kms_key_id                    = "arn:aws:kms:region:account-id:key/key-id"
  backup_retention_period       = 7
}
```

### Example 2: Aurora Serverless v2

```hcl
module "aurora_rds_cluster" {
  source = "https://github.com/opstimus/terraform-aws-aurora?ref=v<RELEASE>"

  project                       = "my-project"
  environment                   = "production"
  vpc_id                        = "vpc-123456"
  private_subnet_ids            = ["subnet-123", "subnet-456"]
  vpc_cidr                      = "10.0.0.0/16"
  engine                        = "aurora-postgresql"
  engine_version                = "15.4"
  db_name                       = "mydb"
  master_username               = "admin"
  parameter_group_family        = "aurora-postgresql15"
  storage_encrypted             = true
  kms_key_id                    = "arn:aws:kms:region:account-id:key/key-id"
  backup_retention_period       = 7
  enable_serverless_v2          = true
  serverless_v2_min_capacity    = 0.5
  serverless_v2_max_capacity    = 16
  instance_count                = 0
}
```

## Notes

The name for the created resource follows the pattern `{project}-{environment}-resource-type`.

### Aurora Serverless v2

When `enable_serverless_v2` is set to `true`, the module configures Aurora Serverless v2 scaling. With Serverless v2:
- The cluster uses `engine_mode = "provisioned"` with serverless v2 scaling configuration
- Cluster instances use the `db.serverless` instance class automatically
- Scaling is handled automatically based on the `serverless_v2_min_capacity` and `serverless_v2_max_capacity` values
- Valid ACU values: 0.5, 1, 2, 4, 8, 16, 32, 64, 128, 256
- You can still use read replicas with Serverless v2 by setting `instance_count > 0`
