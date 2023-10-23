# AWS Aurora RDS Cluster

## Description

This Terraform module creates an Aurora RDS cluster with multiple configurable options including instance count, engine type, engine version, and more.

The module also creates an associated security group and stores the database password in AWS Secrets Manager.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | ~> 4.0 |
| random | >= 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 4.0 |
| random | >= 3.4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project | The project name. | `string` | - | yes |
| environment | The environment name. | `string` | - | yes |
| parameter_group_family | The family of the DB parameter group. | `string` | - | yes |
| instance_count | The number of instances in the RDS cluster. | `number` | `1` | no |
| engine_mode | The database engine mode. | `string` | `"provisioned"` | no |
| engine | The database engine to use. | `string` | - | yes |
| engine_version | The version number of the database engine to use. | `string` | - | yes |
| db_name | The name of the database. | `string` | - | yes |
| master_username | The username for the master DB user. | `string` | `"admin"` | no |
| skip_final_snapshot | Determines whether a final DB snapshot is created before the DB instance is deleted. | `bool` | `true` | no |
| deletion_protection | Enable or disable deletion protection. | `bool` | `false` | no |
| enabled_cloudwatch_logs_exports | The list of log types to export to CloudWatch. | `list(string)` | - | yes |
| backup_retention_period | The number of days for which automated backups are retained. | `number` | `30` | no |
| storage_encrypted | Specifies whether the DB instance is encrypted. | `bool` | `false` | no |
| kms_key_id | The ARN for the KMS encryption key. | `string` | - | yes |
| network_type | The type of network for the DB cluster. | `string` | `"IPV4"` | no |
| performance_insights_enabled | Enable or disable performance insights. | `bool` | `false` | no |
| instancetype | The instance type of the RDS instance(s). | `string` | `"db.t3.medium"` | no |
| vpc_id | The VPC ID where the RDS cluster will be created. | `string` | - | yes |
| private_subnet_ids | The IDs of the private subnets where the RDS cluster will be created. | `list(string)` | - | yes |
| vpc_cidr | The CIDR block for the VPC. | `string` | - | yes |
| parameter_group_parameters | A list of DB parameters to apply. | `list(object)` | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| db_password_secret | The name of the Secret in Secrets Manager that contains the DB password. |

## Example Usage

```hcl
module "aurora_rds_cluster" {
  source          = "s3::https://s3.amazonaws.com/ot-turbo-artifacts/tf/modules/aws/dev/aurora.zip"

  project         = "my_project"
  environment     = "my_environment"
  parameter_group_family = "my_family"
  engine          = "aurora-mysql"
  engine_version  = "8.0.mysql_aurora.3.03.0"
  db_name         = "my_database"
  vpc_id          = "vpc-0example0"
  private_subnet_ids = ["subnet-0example1", "subnet-0example2"]
  vpc_cidr        = "10.0.0.0/16"
  kms_key_id      = "arn:aws:kms:region:account:key/example"
  parameter_group_parameters = [
    {
      name  = "time_zone",
      value = "UTC"
    }
  ]
}
```

## Notes

The name for the created resource follows the pattern `{project}-{environment}-resource-type`.
