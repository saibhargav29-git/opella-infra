terraform {
  required_version = ">= 1.14.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate-opella"
    storage_account_name = "stateopella01"
    container_name       = "tfstate"
    key                  = "dev/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

locals {
  environment = "dev"
  location    = var.location
  name_prefix = "opella-${local.environment}"

  common_tags = {
    environment = local.environment
    region      = var.location
    managed_by  = "terraform"
    project     = "opella-infra"
    owner       = "devops"
  }
}

# ── Resource Group ──────────────────────────────────────────
resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name_prefix}-${var.location}"
  location = local.location
  tags     = local.common_tags
}

# ── VNET Module ─────────────────────────────────────────────
module "vnet" {
  source = "../../modules/vnet"

  vnet_name           = "vnet-${local.name_prefix}-${var.location}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = var.vnet_address_space

  subnets = {
    "snet-app" = {
      address_prefix = var.subnet_app_prefix
    }
    "snet-data" = {
      address_prefix = var.subnet_data_prefix
    }
  }

  enable_ddos_protection = false
  tags                   = local.common_tags
}

# ── NSG Rule: Allow SSH on app subnet ────────────────────────
resource "azurerm_network_security_rule" "ssh" {
  name                        = "allow-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = module.vnet.nsg_names["snet-app"]
}

# ── Storage Account + Blob Container ────────────────────────
resource "azurerm_storage_account" "this" {
  name                            = "sto${local.environment}opella001"
  resource_group_name             = azurerm_resource_group.this.name
  location                        = azurerm_resource_group.this.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = local.common_tags
}

resource "azurerm_storage_container" "this" {
  name                  = "artifacts"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

# ── Network Interface for VM ─────────────────────────────────
resource "azurerm_network_interface" "this" {
  name                = "nic-${local.name_prefix}-vm"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.subnet_ids["snet-app"]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

# ── Public IP ────────────────────────────────────────────────
resource "azurerm_public_ip" "this" {
  name                = "pip-${local.name_prefix}-vm"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

# ── Linux Virtual Machine ────────────────────────────────────
resource "azurerm_linux_virtual_machine" "this" {
  name                  = "vm-${local.name_prefix}"
  resource_group_name   = azurerm_resource_group.this.name
  location              = azurerm_resource_group.this.location
  size                  = var.vm_size
  admin_username        = var.vm_admin_username
  network_interface_ids = [azurerm_network_interface.this.id]
  tags                  = local.common_tags

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}