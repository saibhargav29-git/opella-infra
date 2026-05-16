output "resource_group_name" {
  description = "Name of the prod resource group"
  value       = azurerm_resource_group.this.name
}

output "vnet_id" {
  description = "ID of the prod Virtual Network"
  value       = module.vnet.vnet_id
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = module.vnet.subnet_ids
}

output "vm_public_ip" {
  description = "Public IP address of the prod Virtual Machine"
  value       = azurerm_public_ip.this.ip_address
}

output "vm_name" {
  description = "Name of the prod Virtual Machine"
  value       = azurerm_linux_virtual_machine.this.name
}

output "storage_account_name" {
  description = "Name of the prod Storage Account"
  value       = azurerm_storage_account.this.name
}