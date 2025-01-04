terraform {
  # Specify versions to avoid breaking changes.
  required_version = "1.10.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.14.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.0.2"
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
  name                     = "aurora${var.environment}42" # Global unique name
  resource_group_name      = azurerm_resource_group.aurora.name
  location                 = azurerm_resource_group.aurora.location
  sku                      = "Basic"
  admin_enabled            = true
  tags = {
    Environment = var.environment
  }
}

resource "azurerm_container_group" "aurora" {
  name                = "aurora-${var.environment}-cg"
  resource_group_name = azurerm_resource_group.aurora.name
  location            = azurerm_resource_group.aurora.location
  os_type             = "Linux"

  image_registry_credential {
    server   = azurerm_container_registry.aurora.login_server
    username = azurerm_container_registry.aurora.admin_username
    password = azurerm_container_registry.aurora.admin_password
  }

  container {
    name   = "aurora"
    image  = "${azurerm_container_registry.aurora.login_server}/aurora:latest"
    cpu    = "0.5"
    memory = "1.5"
    ports {
      port     = 8080
      protocol = "TCP"
    }
  }

  tags = {
    Environment = var.environment
  }
}

# Give GitHub Actions permissions to apply Terraform changes
resource "azuread_application" "github_actions_terraform_apply" {
  display_name = "github-actions-terraform-apply"
}

resource "azuread_service_principal" "github_actions_terraform_apply" {
  client_id = azuread_application.github_actions_terraform_apply.client_id
}

resource "azuread_service_principal_password" "github_actions_terraform_apply" {
  service_principal_id = azuread_service_principal.github_actions_terraform_apply.id
}

resource "azurerm_role_assignment" "terraform_apply" {
  scope                = azurerm_resource_group.aurora.id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.github_actions_terraform_apply.object_id
}

# Give GitHub Actions permissions to push to the container registry
resource "azuread_application" "github_actions_acr_push" {
  display_name = "github-actions-acr-push"
}

resource "azuread_service_principal" "github_actions_acr_push" {
  client_id = azuread_application.github_actions_acr_push.client_id
}

resource "azuread_service_principal_password" "github_actions_acr_push" {
  service_principal_id = azuread_service_principal.github_actions_acr_push.id
}

resource "azurerm_role_assignment" "acr_push" {
  scope                = azurerm_container_registry.aurora.id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.github_actions_acr_push.object_id
}
