# OCI PostgreSQL Module

## Description

Provisions an OCI PostgreSQL DB system with a dedicated network security group that permits ingress on port 5432 from specified CIDRs. A random 16-character password is generated and stored as an OCI Vault secret, and a daily backup policy is configured. Instance count scaling is managed via a local-exec provisioner so the DB system lifecycle ignores count changes after initial creation.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| oracle/oci | >= 8.0 |
| hashicorp/random | >= 3.4.0 |
| hashicorp/null | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| oracle/oci | >= 8.0 |
| hashicorp/random | >= 3.4.0 |
| hashicorp/null | >= 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project | The name of the project. | `string` | - | yes |
| environment | The environment (e.g., dev, prod). | `string` | - | yes |
| name | The name of the resource. | `string` | - | yes |
| compartment_id | The OCID of the compartment. | `string` | - | yes |
| vcn_id | The OCID of the VCN where the database system will be created. | `string` | - | yes |
| allowed_cidrs | List of CIDR blocks permitted to reach the PostgreSQL cluster on port 5432. Pass your application-tier subnet CIDRs. | `list(string)` | - | yes |
| kms_vault_id | The OCID of the KMS vault to use for storing the database password. | `string` | - | yes |
| kms_key_id | The OCID of the KMS key to use for encrypting the database password. | `string` | - | yes |
| db_version | The version of the database. | `string` | - | yes |
| instance_count | The number of database instances to create. | `number` | - | yes |
| db_system_shape | The shape of the database system. | `string` | - | yes |
| db_username | The username for the database. | `string` | - | yes |
| subnet_id | The OCID of the subnet where the database will be created. | `string` | - | yes |
| availability_domain | The availability domain to create the database system in. If not specified, the database system will be created as a regional resource with high availability across availability domains. | `string` | - | yes |
| storage_iops | The number of IOPS to provision for the database system's storage. | `number` | - | yes |
| instance_memory_size_in_gbs | The amount of memory (in GBs) to allocate for each database instance. | `number` | - | yes |
| instance_ocpu_count | The number of OCPUs to allocate for each database instance. | `number` | - | yes |
| is_reader_endpoint_enabled | Whether to enable the reader endpoint for the database system. | `bool` | `false` | no |
| backup_start_time | The start time for the backup schedule. | `string` | `"02:00"` | no |
| backup_retention_days | The number of days to retain backups. | `number` | `14` | no |
| db_source_type | The source type for the database system. | `string` | `"NONE"` | no |
| db_backup_id | The OCID of the backup to use as the source for the database system. | `string` | `null` | no |
| tags | Free-form tags to apply to the resource. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| db_username | The username for the database. |
| db_version | The version of the database. |
| db_dns | The DNS name of the database. |
| db_system_id | The OCID of the PostgreSQL DB system. |
| nsg_id | The OCID of the network security group attached to the DB system. |
| secret_id | The OCID of the vault secret containing the database password. |

## Usage examples

### Basic Usage Example

```hcl
module "postgresql" {
  source = "git::https://github.com/opstimus/terraform-modules.git//modules/oci-postgresql?ref=oci-postgresql/v<RELEASE>"

  project        = "myapp"
  environment    = "prod"
  name           = "primary"
  compartment_id = "ocid1.compartment.oc1..example"
  vcn_id         = "ocid1.vcn.oc1..example"
  subnet_id      = "ocid1.subnet.oc1..example"
  allowed_cidrs  = ["10.0.1.0/24"]
  kms_vault_id   = "ocid1.vault.oc1..example"
  kms_key_id     = "ocid1.key.oc1..example"
  db_version              = "14"
  db_system_shape         = "PostgreSQL.VM.Standard.E4.Flex.2.32GB"
  db_username             = "appuser"
  instance_count          = 1
  instance_memory_size_in_gbs = 32
  instance_ocpu_count     = 2
  storage_iops            = 3000
  availability_domain     = null
}
```
