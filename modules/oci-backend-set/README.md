# OCI Backend Set Module

## Description

Creates an OCI Load Balancer backend set with a configurable health checker, registers a backend IP and port via local-exec scripts, and upserts a routing rule into an existing shared routing policy. The backend registration and routing rule lifecycle are managed through shell scripts so that OCI CLI state and Terraform state remain in sync.

## Requirements

| Name      | Version    |
|-----------|------------|
| terraform | >= 1.3.0   |
| oci       | >= 8.0     |
| null      | >= 3.2     |

## Providers

| Name | Version |
|------|---------|
| oracle/oci     | >= 8.0 |
| hashicorp/null | >= 3.2 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project | Project name used in resource naming. | `string` | - | yes |
| environment | Environment name used in resource naming. | `string` | - | yes |
| name | Component name used in resource naming. | `string` | - | yes |
| load_balancer_id | OCID of the load balancer (owned by iac_base). | `string` | - | yes |
| backend_set_policy | Load balancing policy for the backend set. One of: `ROUND_ROBIN`, `LEAST_CONNECTIONS`, `IP_HASH`. | `string` | `"ROUND_ROBIN"` | no |
| backend_set_health_checker_protocol | Protocol for health checks. One of: `HTTP`, `HTTPS`, `TCP`. | `string` | - | yes |
| backend_set_health_checker_port | Port on the backend to use for health checks. | `number` | - | yes |
| backend_set_health_checker_url_path | URL path for HTTP/HTTPS health checks. | `string` | `"/"` | no |
| backend_set_health_checker_return_code | Expected HTTP return code for HTTP/HTTPS health checks. | `number` | `200` | no |
| backend_set_health_checker_interval_ms | Interval between health checks in milliseconds. | `number` | `10000` | no |
| backend_set_health_checker_timeout_in_millis | Timeout for each health check in milliseconds. | `number` | `3000` | no |
| backend_set_health_checker_retries | Number of retries before marking the backend as unhealthy. | `number` | `3` | no |
| backend_ip_address | Private IP address of the backend instance. | `string` | - | yes |
| backend_port | Port on the backend instance to forward traffic to. | `number` | - | yes |
| routing_policy_name | Name of the routing policy (owned by iac_base) into which this module upserts its rule. | `string` | - | yes |
| routing_condition | OCI routing policy condition expression (e.g. `"http.request.url.path sw '/api/v1'"` for path-based routing). | `string` | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| backend_set_name | Name of the created backend set. |
| backend_set_id | Composite identifier (`loadBalancers/{lb-ocid}/backendSets/{name}`) of the backend set. This is not an OCID. |
| rule_name | Name of the routing rule upserted into the shared routing policy. |
| backend_address | Registered backend address in `ip:port` format. |

## Usage examples

### Basic Usage Example

```hcl
module "oci_backend_set" {
  source = "git::https://github.com/opstimus/terraform-modules.git//modules/oci-backend-set?ref=oci-backend-set/v<RELEASE>"

  project     = "myapp"
  environment = "prod"
  name        = "api"

  load_balancer_id = "ocid1.loadbalancer.oc1.phx.exampleid"

  backend_set_health_checker_protocol = "HTTP"
  backend_set_health_checker_port     = 8080

  backend_ip_address = "10.0.1.10"
  backend_port       = 8080

  routing_policy_name = "myapp-prod-routing-policy"
  routing_condition   = "http.request.url.path sw '/api/v1'"
}
```
