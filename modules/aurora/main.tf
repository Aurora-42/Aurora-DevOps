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

resource "azurerm_resource_group" "aurora" {
  name     = "aurora-${var.environment}-rg"
  location = var.location
  tags = {
    Environment = var.environment
  }
}
