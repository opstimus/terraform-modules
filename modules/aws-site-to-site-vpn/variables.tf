variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "name" {
  type        = string
  description = "Service name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "customer_gateway_ip_address" {
  type        = string
  description = "On-prem location ISP Public IP address"
}

variable "device_name" {
  type        = string
  description = "Customer Gateway Device Name"
}

variable "local_ipv4_network_cidr" {
  type        = string
  description = "The local (On-prem) IPv4 network CIDR for the VPN connection"
}

variable "route_table_ids" {
  type        = list(string)
  description = "List of Route Table IDs to propagate the VPN routes to"
}
