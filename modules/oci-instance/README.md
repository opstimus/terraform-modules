# OCI Instance Module

## Description

This module provisions an OCI compute instance with a dedicated Network Security Group (NSG) that has configurable ingress rules and allow-all egress. It optionally assigns a reserved public IP to the instance's primary VNIC.

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
| project | The name of the project. | `string` | - | yes |
| environment | The environment (e.g., dev, prod). | `string` | - | yes |
| name | The name of the resource. | `string` | - | yes |
| compartment_id | The OCID of the compartment where the instance will be created. | `string` | - | yes |
| vcn_id | The OCID of the VCN where the NSG will be created. | `string` | - | yes |
| availability_domain | The availability domain where the instance will be created. | `string` | - | yes |
| shape | The shape of the instance (e.g., VM.Standard.E4.Flex). | `string` | - | yes |
| subnet_id | The OCID of the subnet where the instance will be created. | `string` | - | yes |
| source_id | The OCID of the image to use for the instance. | `string` | - | yes |
| nsg_ingress_rules | A map of ingress rules to create in the NSG. The key is a unique identifier for each rule. | `map(object({ protocol = string, source = string, source_type = optional(string, "CIDR_BLOCK"), port_min = optional(number, null), port_max = optional(number, null), description = optional(string, "") }))` | `{}` | no |
| assign_reserved_public_ip | Whether to assign a reserved public IP to the instance. | `bool` | `false` | no |
| assign_public_ip | Whether to auto assign public IP address to the instance. | `bool` | `true` | no |
| skip_source_dest_check | Whether to skip source/destination check on the instance's primary VNIC. | `bool` | `false` | no |
| ocpus | The number of OCPUs to allocate to the instance (applicable for flexible shapes). | `number` | `1` | no |
| memory_in_gbs | The amount of memory in GBs to allocate to the instance (applicable for flexible shapes). | `number` | `8` | no |
| licensing_configs_type | The type of licensing configuration (e.g., OCI_PROVIDED, BRING_YOUR_OWN_LICENSE). Set to null for Linux images. | `string` | `null` | no |
| licensing_configs_license_type | The license type for the instance (e.g., OCI_PROVIDED, WINDOWS_SERVER_DATACENTER, BRING_YOUR_OWN_LICENSE). Set to null for Linux images. | `string` | `null` | no |
| boot_volume_size_in_gbs | The size of the boot volume in GBs. | `number` | `50` | no |
| source_type | The type of the source for the instance. | `string` | `"image"` | no |
| kms_key_id | The OCID of the KMS key to encrypt the boot volume. | `string` | `null` | no |
| tags | Free-form tags to apply to the instance resources. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | The OCID of the compute instance. |
| nsg_id | The ID of the Network Security Group associated with the instance. |
| private_ip | The private IP address of the instance's primary VNIC. |
| public_ip | The public IP address of the instance's primary VNIC. |
| reserved_public_ip | The reserved public IP address assigned to the instance. |

## Usage examples

### Basic Usage Example

```hcl
module "oci_instance" {
  source = "git::https://github.com/opstimus/terraform-modules.git//modules/oci-instance?ref=oci-instance/v<RELEASE>"

  project             = "myapp"
  environment         = "prod"
  name                = "web-server"
  compartment_id      = "ocid1.compartment.oc1..examplecompartmentid"
  vcn_id              = "ocid1.vcn.oc1.eu-frankfurt-1.examplevcnid"
  availability_domain = "iBMi:EU-FRANKFURT-1-AD-1"
  shape               = "VM.Standard.E4.Flex"
  subnet_id           = "ocid1.subnet.oc1.eu-frankfurt-1.examplesubnetid"
  source_id           = "ocid1.image.oc1.eu-frankfurt-1.exampleimageid"
}
```
