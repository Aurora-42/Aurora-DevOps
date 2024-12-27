terraform {
  # Specify versions to avoid breaking changes.
  required_version = "1.10.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.14.0"
    }
  }

  # Backend configuration determines where Terraform stores its state files.
  # State files are used to track the current state of your infrastructure.
  # Using a backend instead of local state is essential for team collaboration.
  # Note: You must first create the resource group, storage account, and container
  #       before creating the backend configuration.
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateaurora42"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "tfstate" {
  name     = "tfstate-rg"
  location = var.location
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "tfstateaurora42" # Global unique name
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}
