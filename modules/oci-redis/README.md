# OCI Redis Module

## Description

Provisions an OCI Redis cluster with a dedicated network security group that permits ingress on port 6379 from specified CIDRs. Supports both SHARDED and NONSHARDED cluster modes, and optionally creates a cache config set with custom Redis key-value configuration parameters applied to the cluster.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| oracle/oci | >= 8.0 |

## Providers

| Name | Version |
|------|---------|
| oracle/oci | >= 8.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project | The name of the project. | `string` | - | yes |
| environment | The environment (e.g., dev, prod). | `string` | - | yes |
| name | The name of the resource. | `string` | - | yes |
| compartment_id | The OCID of the compartment where the VCN will be created. | `string` | - | yes |
| vcn_id | The OCID of the VCN where the NSG will be created. | `string` | - | yes |
| node_count | The number of nodes in the Redis cluster. | `number` | - | yes |
| node_memory_in_gbs | The amount of memory in GBs for each node in the Redis cluster. | `number` | - | yes |
| software_version | The software version of the Redis cluster. | `string` | - | yes |
| subnet_id | The OCID of the subnet where the Redis cluster will be created. | `string` | - | yes |
| cluster_mode | The cluster mode of the Redis cluster (e.g., SHARDED, NONSHARDED.). | `string` | - | yes |
| allowed_cidrs | List of CIDR blocks permitted to reach the Redis cluster on port 6379. Pass your application-tier subnet CIDRs. | `list(string)` | - | yes |
| config_items | Map of Redis configuration key-value pairs for the cache config set. Leave empty to skip creating the config set (e.g. { maxmemory-policy = "allkeys-lru", hz = "15" }). | `map(string)` | `{}` | no |
| shard_count | The number of shards in the Redis cluster (required if cluster_mode is SHARDED). | `number` | `0` | no |
| tags | Free-form tags to apply to the VCN. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The ID of the Redis cluster. |
| nsg_id | The IDs of the Network Security Groups associated with the Redis cluster. |
| primary_fqdn | The primary FQDN of the Redis cluster. |
| primary_endpoint_ip_address | The primary endpoint IP address of the Redis cluster. |
| software_version | The software version of the Redis cluster. |

## Usage examples

### Basic Usage Example

```hcl
module "redis" {
  source = "git::https://github.com/opstimus/terraform-modules.git//modules/oci-redis?ref=oci-redis/v<RELEASE>"

  project        = "myapp"
  environment    = "prod"
  name           = "cache"
  compartment_id = "ocid1.compartment.oc1..example"
  vcn_id         = "ocid1.vcn.oc1..example"
  subnet_id      = "ocid1.subnet.oc1..example"
  allowed_cidrs  = ["10.0.1.0/24"]
  node_count         = 2
  node_memory_in_gbs = 4
  software_version   = "REDIS_7_0"
  cluster_mode       = "NONSHARDED"
}
```
