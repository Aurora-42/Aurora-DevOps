terraform {
  # Specify versions to avoid breaking changes.
  required_version = "1.10.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.14.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource group for the Terraform state
# This is used by the Terraform azurerm backend to store the Terraform state files
resource "azurerm_resource_group" "tfstate" {
  name     = "tfstate-${var.environment}-rg"
  location = var.location
  tags = {
    Environment = var.environment
  }
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "tfstate${var.environment}aurora42" # Global unique name
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    Environment = var.environment
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

# Resource group for the Aurora infrastructure
resource "azurerm_resource_group" "aurora" {
  name     = "aurora-${var.environment}-rg"
  location = var.location
  tags = {
    Environment = var.environment
  }
}

resource "azurerm_container_registry" "aurora" {
  name                     = "aurora${var.environment}42"
  resource_group_name      = azurerm_resource_group.aurora.name
  location                 = azurerm_resource_group.aurora.location
  sku                      = "Basic"
  admin_enabled            = true
  tags = {
    Environment = var.environment
  }
}
