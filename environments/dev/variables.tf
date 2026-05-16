variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Azure region for dev environment resources"
  type        = string
  default     = "eastus"
}

variable "vnet_address_space" {
  description = "Address space for the dev VNET in CIDR notation"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_app_prefix" {
  description = "CIDR prefix for the application subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_data_prefix" {
  description = "CIDR prefix for the data subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "vm_size" {
  description = "Azure VM size. Use Standard_B1s for free tier eligibility."
  type        = string
  default     = "Standard_B1s"
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