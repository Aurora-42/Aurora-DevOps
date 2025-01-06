# Resource group for the Terraform state
# This is used by the Terraform azurerm backend to store the Terraform state files
resource "azurerm_resource_group" "tfstate" {
  name     = "tfstate-${var.environment}-aurora-rg"
  location = var.location
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "tfstate${var.environment}aurora42" # Global unique name
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
