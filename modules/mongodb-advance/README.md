# MongoDB Cluster Module

## Description

This module sets up a MongoDB Cluster along with necessary resources. Also this creates aws-secrets and store database user password and mongo SRV connection string in parameter store.

## Requirements

| Name       | Version   |
|------------|-----------|
| terraform  | >= 1.3.0  |
| mongodb    | >= 1.22.0 |
| aws        | >= 4.0    |
| random     | >= 3.5.1  |

## Providers

| Name  | Version   |
|-------|-----------|
| aws   | >= 4.0    |
| mongo | >= 1.22.0 |
| random| >= 3.5.1  |

## Inputs

| Name                             | Description                                              | Type              | Default              | Required |
|----------------------------------|----------------------------------------------------------|-------------------|----------------------|:--------:|
| project                          | Project name                                             | `string`          | -                    | yes      |
| environment                      | Environment name                                         | `string`          | -                    | yes      |
| name                             | Service Name                                             | `string`          | -                    | yes      |
| atlast_org_id                    | Atlas organization ID                                    | `string`          | -                    | yes      |
| atlas_api_public_key             | Atlas auhentication public key                           | `string`          | -                    | yes      |
| atlas_api_private_key            | Atlas auhentication private key                          | `string`          | -                    | yes      |
| provider name                    | Backend provider name                                    | `string`          | "AWS"                | yes      |
| region                           | The region cluster should deploy                         | `string`          | -                    | yes      |
| cluster_type                     | Cluster type                                             | `string`          | "REPLICASET"         | yes      |
| db_version                       | Mongo database version                                   | `string`          | "6.0"                | yes      |
| backup_enabled                   | Enable auto backup                                       | `bool`            | false                | no       |
| termination_protection_enabled   | Enable deletion protection for the cluster               | `bool`            | false                | no       |
| instance_size                    | Cluster size                                             | `string`          | ""                   | yes      |
| disk_size_gb                     | Disk capacity                                            | `number`          | 10                   | no       |
| db_username                      | Master username for the DB                               | `string`          | "admin"              | no       |
| db_name                          | Default database name                                    | `string`          | -                    | yes      |
| witelist_ip_addresses            | IP Address that should be able to access the database    | `map(string)`     | {}                   | yes      |


## Outputs

| Name              | Description                                   |
|-------------------|-----------------------------------------------|
| db_password_secret| Name of the Secrets Manager secret for DB password |


## Usage examples

### Example 1

```hcl
module "mongodb_cluster" {
  source = "https://github.com/opstimus/terraform-mongodb-advance?ref=v<RELEASE>"

  project                       = "my-project"
  environment                   = "production"
  name                          = "authentication"
  atlast_org_id                 = "a1b2c3"
  atlas_api_public_key          = "atlas_api_public_key"
  # atlas_api_private_key       = "<atlas_api_private_key>"
  provider_name                 = "AWS"
  region                        = "AP_SOUTHEAST_1"
  cluster_type                  = "REPLICASET"
  instance_size                 = "M10"
  disk_size_gb                  = 10
  db_version                    = "6.0"
  db_username                   = "admin"
  db_name                       = "authentication_api"
  witelist_ip_addresses         = {
                                    "Location1" = "192.168.1.0/32"
                                    "Location2" = "192.168.2.0/32"
                                  }
}
```

## Notes

The name for the created resource follows the pattern `{project}-{environment}-{service-name}`.

For mongodb API key generate: https://www.mongodb.com/docs/atlas/configure-api-access/
