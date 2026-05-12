variable "project" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, prod)."
  type        = string
}

variable "name" {
  description = "The name of the resource."
  type        = string
}

variable "compartment_id" {
  description = "The OCID of the compartment where the VCN will be created."
  type        = string
}

variable "vcn_id" {
  description = "The OCID of the VCN where the NSG will be created."
  type        = string
}

variable "config_key" {
  description = "The configuration key for the Redis cache config set."
  type        = string
}

variable "config_value" {
  description = "The configuration value for the Redis cache config set."
  type        = string
  sensitive   = true
}

variable "node_count" {
  description = "The number of nodes in the Redis cluster."
  type        = number
}

variable "node_memory_in_gbs" {
  description = "The amount of memory in GBs for each node in the Redis cluster."
  type        = number
}

variable "software_version" {
  description = "The software version of the Redis cluster."
  type        = string
}

variable "subnet_id" {
  description = "The OCID of the subnet where the Redis cluster will be created."
  type        = string
}

variable "cluster_mode" {
  description = "The cluster mode of the Redis cluster (e.g., SHARDED, NON_SHARDED)."
  type        = string
}

variable "shard_count" {
  description = "The number of shards in the Redis cluster (required if cluster_mode is SHARDED)."
  type        = number
}

variable "allowed_cidrs" {
  description = "List of CIDR blocks permitted to reach the Redis cluster on port 6379. Pass your application-tier subnet CIDRs."
  type        = list(string)
}

variable "tags" {
  description = "Free-form tags to apply to the VCN."
  type        = map(string)
  default     = null
}
