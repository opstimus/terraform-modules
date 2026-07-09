# OCI KMS Vault Module

## Description

Creates an Oracle Cloud Infrastructure (OCI) KMS vault of type DEFAULT in the specified compartment. The vault display name is composed from the `project`, `environment`, and `name` inputs, and the module exposes the vault OCID and management endpoint for use by downstream key resources.

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
| tags | Free-form tags to apply to the resource. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| vault\_id | The OCID of the KMS vault. |
| management\_endpoint | The management endpoint of the KMS vault. |

## Usage examples

### Basic Usage Example

```hcl
module "kms_vault" {
  source = "git::https://github.com/opstimus/terraform-modules.git//modules/oci-kms-vault?ref=oci-kms-vault/v<RELEASE>"

  project        = "myapp"
  environment    = "prod"
  name           = "secrets-vault"
  compartment_id = "ocid1.compartment.oc1..exampleuniqueID"
}
```
