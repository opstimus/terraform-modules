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

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}
