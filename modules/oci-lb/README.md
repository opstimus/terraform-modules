# OCI Load Balancer Module

## Description

This module provisions a flexible OCI load balancer with HTTP and HTTPS listeners, automatic HTTP-to-HTTPS redirect, a path-based routing policy, separate HTTP and HTTPS backend sets, and a dedicated NSG with pre-configured port 80/443 ingress rules. SSL termination is handled at the listener using the provided certificate OCIDs.

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
| vcn_id | The OCID of the VCN where the load balancer will be created. | `string` | - | yes |
| compartment_id | The OCID of the compartment where the resources will be created. | `string` | - | yes |
| subnet_ids | A list of subnet OCIDs to be used for the load balancer. | `list(string)` | - | yes |
| listener_ssl_configuration_certificate_ids | A list of certificate OCIDs to be associated with the backend set for SSL termination. | `list(string)` | - | yes |
| is_private | Whether the load balancer is private or public. | `bool` | `false` | no |
| is_request_id_enabled | Whether to enable request ID header for the load balancer. | `bool` | `false` | no |
| security_attributes | The security attributes for the load balancer. | `map(string)` | `null` | no |
| maximum_bandwidth_in_mbps | The maximum bandwidth in Mbps for the load balancer shape. | `number` | `1000` | no |
| minimum_bandwidth_in_mbps | The minimum bandwidth in Mbps for the load balancer shape. | `number` | `10` | no |
| backend_set_policy | The load balancing policy for the backend set (e.g., ROUND_ROBIN, LEAST_CONNECTIONS, IP_HASH). | `string` | `"ROUND_ROBIN"` | no |
| health_check_url_path | The URL path for the health check (e.g., /health). | `string` | `"/health"` | no |
| health_check_port | The port on the backend to use for health checks. | `number` | `80` | no |
| listener_connection_configuration_idle_timeout_in_seconds | The idle timeout in seconds for the listener connection configuration. | `number` | `60` | no |
| tags | Free-form tags to apply to all resources in this module. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| load_balancer_id | The OCID of the load balancer. |
| load_balancer_ip_addresses | The IP address details of the load balancer. |
| public_ip_address | The public IP address assigned to the load balancer by OCI. Null when the load balancer is private. |
| nsg_id | The OCID of the NSG attached to the load balancer. Add this to backend compute instances to allow LB egress traffic. |
| http_backend_set_name | The name of the HTTP backend set. |
| https_backend_set_name | The name of the HTTPS backend set. |
| routing_policy_name | The name of Routing policy. |

## Usage examples

### Basic Usage Example

```hcl
module "oci_lb" {
  source = "git::https://github.com/opstimus/terraform-modules.git//modules/oci-lb?ref=oci-lb/v<RELEASE>"

  project        = "myapp"
  environment    = "prod"
  compartment_id = "ocid1.compartment.oc1..examplecompartmentid"
  vcn_id         = "ocid1.vcn.oc1.eu-frankfurt-1.examplevcnid"
  subnet_ids     = ["ocid1.subnet.oc1.eu-frankfurt-1.examplesubnetid"]
  listener_ssl_configuration_certificate_ids = ["ocid1.certificate.oc1.eu-frankfurt-1.examplecertid"]
}
```
