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
  description = "The OCID of the compartment where the instance will be created."
  type        = string
}

variable "vcn_id" {
  description = "The OCID of the VCN where the NSG will be created."
  type        = string
}

variable "nsg_ingress_rules" {
  type = map(object({
    protocol    = string
    source      = string
    source_type = optional(string, "CIDR_BLOCK")
    port_min    = optional(number, null)
    port_max    = optional(number, null)
    description = optional(string, "")
  }))
  description = "A map of ingress rules to create in the NSG. The key is a unique identifier for each rule."
  default     = {}
}

variable "availability_domain" {
  description = "The availability domain where the instance will be created."
  type        = string
}

variable "shape" {
  description = "The shape of the instance (e.g., VM.Standard.E4.Flex)."
  type        = string
}

variable "assign_reserved_public_ip" {
  description = "Whether to assign a reserved public IP to the instance."
  type        = bool
  default     = false
}

variable "assign_public_ip" {
  description = "Whether to auto assign public IP address to the instance."
  type        = bool
  default     = true
}

variable "skip_source_dest_check" {
  description = "Whether to skip source/destination check on the instance's primary VNIC."
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "The OCID of the subnet where the instance will be created."
  type        = string
}

variable "ocpus" {
  description = "The number of OCPUs to allocate to the instance (applicable for flexible shapes)."
  type        = number
  default     = 1
}

variable "memory_in_gbs" {
  description = "The amount of memory in GBs to allocate to the instance (applicable for flexible shapes)."
  type        = number
  default     = 8
}

variable "licensing_configs_type" {
  description = "The type of licensing configuration (e.g., OCI_PROVIDED, BRING_YOUR_OWN_LICENSE). Set to null for Linux images."
  type        = string
  default     = null
}

variable "licensing_configs_license_type" {
  description = "The license type for the instance (e.g., OCI_PROVIDED, WINDOWS_SERVER_DATACENTER, BRING_YOUR_OWN_LICENSE). Set to null for Linux images."
  type        = string
  default     = null
}

variable "source_id" {
  description = "The OCID of the image to use for the instance."
  type        = string
}

variable "boot_volume_size_in_gbs" {
  description = "The size of the boot volume in GBs."
  type        = number
  default     = 50
}

variable "source_type" {
  description = "The type of the source for the instance."
  type        = string
  default     = "image"
}

variable "kms_key_id" {
  description = "The OCID of the KMS key to encrypt the boot volume."
  type        = string
  default     = null
}

variable "tags" {
  description = "Free-form tags to apply to the instance resources."
  type        = map(string)
  default     = null
}
