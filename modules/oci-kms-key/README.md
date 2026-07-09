# OCI KMS Key Module

## Description

Creates an Oracle Cloud Infrastructure (OCI) KMS cryptographic key within an existing vault. The key display name is composed from the `project`, `environment`, and `name` inputs, and the module enforces algorithm-specific key length and curve constraints via lifecycle preconditions.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| oci | >= 8.0 |

## Providers

| Name | Version |
|------|---------|
| oci | >= 8.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project | The name of the project. | `string` | `-` | yes |
| environment | The environment (e.g., dev, prod). | `string` | `-` | yes |
| name | The name of the resource. | `string` | `-` | yes |
| compartment\_id | The OCID of the compartment. | `string` | `-` | yes |
| kms\_vault\_management\_endpoint | The management endpoint for the KMS vault. | `string` | `-` | yes |
| key\_algorithm | Encryption algorithm for the KMS key. Must be one of: AES, RSA, ECDSA. | `string` | `"AES"` | no |
| key\_length | Key length in bytes. AES: 16/24/32 \| RSA: 256/384/512 \| ECDSA: 32/48/66 | `number` | `32` | no |
| key\_curve\_id | Curve ID for ECDSA keys (P256, P384, P521). Required when algorithm is ECDSA. | `string` | `null` | no |
| tags | Free-form tags to apply to the resource. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| kms\_key\_id | The OCID of the KMS key. |
| kms\_vault\_id | The OCID of the vault that owns this key (computed by the provider). |

## Usage examples

### Basic Usage Example

```hcl
module "kms_key" {
  source = "git::https://github.com/opstimus/terraform-modules.git//modules/oci-kms-key?ref=oci-kms-key/v<RELEASE>"

  project                       = "myapp"
  environment                   = "prod"
  name                          = "app-encryption-key"
  compartment_id                = "ocid1.compartment.oc1..exampleuniqueID"
  kms_vault_management_endpoint = "https://exampleuniqueID-management.kms.us-ashburn-1.oraclecloud.com"
}
```
