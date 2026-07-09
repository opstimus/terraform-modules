# OCI Container Instances Module

## Description

Provisions an OCI Container Instance running one or more containers, along with a dedicated Network Security Group (NSG) that controls inbound traffic with configurable ingress rules and allows all outbound traffic. The module also reads the instance VNIC to expose private IP details as outputs.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.3.0 |
| oci       | >= 8.0   |

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
| compartment_id | The OCID of the compartment where the instance will be created. | `string` | - | yes |
| vcn_id | The OCID of the VCN where the NSG will be created. | `string` | - | yes |
| availability_domain | The availability domain where the instance will be created. | `string` | - | yes |
| shape | The shape of the instance (e.g., `CI.Standard.E4.Flex`). | `string` | - | yes |
| subnet_id | The OCID of the subnet where the instance will be created. | `string` | - | yes |
| ocpus | The number of OCPUs to allocate to the instance (applicable for flexible shapes). | `number` | - | yes |
| memory_in_gbs | The amount of memory in GBs to allocate to the instance (applicable for flexible shapes). | `number` | - | yes |
| containers | Map of containers to run in the instance. The key is used as the container `display_name` if none is provided. | `map(object({ image_url = string, display_name = optional(string, null), arguments = optional(list(string), null), command = optional(list(string), null), environment_variables = optional(map(string), {}) }))` | - | yes |
| nsg_ingress_rules | A map of ingress rules to create in the NSG. The key is a unique identifier for each rule. | `map(object({ protocol = string, source = string, source_type = optional(string, "CIDR_BLOCK"), port_min = optional(number, null), port_max = optional(number, null), description = optional(string, "") }))` | `{}` | no |
| image_pull_secrets | Map of image pull secrets for private container registries. Key is a unique identifier. All fields are required per entry. | `map(object({ registry_endpoint = string, username = string, password = string }))` | `{}` | no |
| container_restart_policy | The restart policy for the container instance. One of: `ALWAYS`, `NEVER`, `ON_FAILURE`. | `string` | `"ALWAYS"` | no |
| is_public_ip_assigned | Whether to assign a public IP to the container instance VNIC. | `bool` | `false` | no |
| tags | Free-form tags to apply to the instance resources. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| nsg_id | The OCID of the Network Security Group associated with the instance. |
| container_instance_id | The OCID of the container instance. |
| vnic_id | The VNIC ID attached to the container instance. |
| private_ip | The private IP address of the container instance. |

## Usage examples

### Basic Usage Example

```hcl
module "oci_container_instances" {
  source = "git::https://github.com/opstimus/terraform-modules.git//modules/oci-container-instances?ref=oci-container-instances/v<RELEASE>"

  project     = "myapp"
  environment = "prod"
  name        = "worker"

  compartment_id      = "ocid1.compartment.oc1..exampleid"
  vcn_id              = "ocid1.vcn.oc1.phx.exampleid"
  subnet_id           = "ocid1.subnet.oc1.phx.exampleid"
  availability_domain = "Uocm:PHX-AD-1"

  shape         = "CI.Standard.E4.Flex"
  ocpus         = 1
  memory_in_gbs = 2

  containers = {
    worker = {
      image_url = "phx.ocir.io/mytenancy/myapp/worker:latest"
      environment_variables = {
        APP_ENV = "prod"
      }
    }
  }
}
```
