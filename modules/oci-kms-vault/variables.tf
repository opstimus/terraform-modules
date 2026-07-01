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
  description = "The OCID of the compartment."
  type        = string
}

variable "tags" {
  description = "Free-form tags to apply to the resource."
  type        = map(string)
  default     = null
}
