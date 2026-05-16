variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Azure region for prod environment resources"
  type        = string
  default     = "eastus"
}

variable "vnet_address_space" {
  description = "Address space for the prod VNET in CIDR notation"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "subnet_app_prefix" {
  description = "CIDR prefix for the application subnet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "subnet_data_prefix" {
  description = "CIDR prefix for the data subnet"
  type        = string
  default     = "10.1.2.0/24"
}

variable "vm_size" {
  description = "Azure VM size for prod environment"
  type        = string
  default     = "Standard_B2ats_v2"
}

variable "vm_admin_username" {
  description = "Admin username for the Linux Virtual Machine"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file for VM authentication"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}