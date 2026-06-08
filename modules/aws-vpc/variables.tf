variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "nat" {
  type        = string
  description = "Valid values: gateway / instance"
}

variable "nat_instance_type" {
  type    = string
  default = "t3.nano"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC cidr"
}

variable "public_cidr_1" {
  type        = string
  description = "Public subnet cird"
}

variable "public_cidr_2" {
  type        = string
  description = "Public subnet cird"
}

variable "public_cidr_3" {
  type        = string
  description = "Public subnet cird"
}

variable "private_cidr_1" {
  type        = string
  description = "Private subnet cird"
}

variable "private_cidr_2" {
  type        = string
  description = "Private subnet cird"
}

variable "private_cidr_3" {
  type        = string
  description = "Private subnet cird"
}

variable "enable_isolated_subnets" {
  type        = bool
  description = "Create isolated private subnets with no outbound internet access."
  default     = false
}

variable "isolated_cidr_1" {
  type        = string
  description = "Isolated subnet CIDR for AZ 1. Required when enable_isolated_subnets is true."
  default     = null
}

variable "isolated_cidr_2" {
  type        = string
  description = "Isolated subnet CIDR for AZ 2. Required when enable_isolated_subnets is true."
  default     = null
}

variable "isolated_cidr_3" {
  type        = string
  description = "Isolated subnet CIDR for AZ 3. Required when enable_isolated_subnets is true."
  default     = null
}

variable "enable_ssm_vpc_endpoints" {
  type        = bool
  description = "Create VPC interface endpoint for SSM in private subnets."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}
