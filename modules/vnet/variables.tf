variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group where the VNET will be created"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "address_space" {
  description = "List of address spaces for the VNET in CIDR notation"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Map of subnet configurations. Key is subnet name, value contains the address prefix."
  type = map(object({
    address_prefix = string
  }))
  default = {}
}

variable "enable_ddos_protection" {
  description = "Enable Azure DDoS Network Protection. Warning: incurs significant additional cost."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Map of tags to apply to all resources in this module"
  type        = map(string)
  default     = {}
}