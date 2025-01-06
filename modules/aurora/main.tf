provider "azurerm" {
  features {}
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

# resource "azurerm_container_group" "aurora" {
#   name                = "aurora-${var.environment}-cg"
#   resource_group_name = azurerm_resource_group.aurora.name
#   location            = azurerm_resource_group.aurora.location
#   os_type             = "Linux"
# 
#   image_registry_credential {
#     server   = azurerm_container_registry.aurora.login_server
#     username = azurerm_container_registry.aurora.admin_username
#     password = azurerm_container_registry.aurora.admin_password
#   }
# 
#   container {
#     name   = "aurora"
#     image  = "${azurerm_container_registry.aurora.login_server}/aurora:latest"
#     cpu    = "0.5"
#     memory = "1.5"
#     ports {
#       port     = 8080
#       protocol = "TCP"
#     }
#   }
# 
#   tags = {
#     Environment = var.environment
#   }
# }

data "azurerm_storage_account" "tfstate" {
  name = "tfstate${var.environment}aurora42"
  resource_group_name = "tfstate-${var.environment}-rg"
}

# Create a GitHub Actions service principal for Terraform
resource "azuread_application" "github_actions_terraform" {
  display_name = "github-actions-${var.environment}-terraform"
}

resource "azuread_service_principal" "github_actions_terraform" {
  client_id = azuread_application.github_actions_terraform.client_id
}

resource "azuread_service_principal_password" "github_actions_terraform" {
  service_principal_id = azuread_service_principal.github_actions_terraform.id
}

data "azurerm_subscription" "current" {}

# Give GitHub Actions permissions to read to the Terraform state storage account
resource "azurerm_role_assignment" "github_actions_terraform" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github_actions_terraform.object_id
}

# Create a GitHub Actions service principal for ACR push
resource "azuread_application" "github_actions_acr_push" {
  display_name = "github-actions-${var.environment}-acr-push"
}

resource "azuread_service_principal" "github_actions_acr_push" {
  client_id = azuread_application.github_actions_acr_push.client_id
}

resource "azuread_service_principal_password" "github_actions_acr_push" {
  service_principal_id = azuread_service_principal.github_actions_acr_push.id
}

# Give GitHub Actions permissions to push to the container registry
resource "azurerm_role_assignment" "acr_push" {
  scope                = azurerm_container_registry.aurora.id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.github_actions_acr_push.object_id
}
