data "azurerm_subscription" "current" {}

# Create a GitHub Actions service principal for Terraform workflow
resource "azuread_application" "github_actions_terraform" {
  display_name = "github-actions-${var.environment}-aurora-terraform"
}

resource "azuread_service_principal" "github_actions_terraform" {
  client_id = azuread_application.github_actions_terraform.client_id
}

resource "azuread_service_principal_password" "github_actions_terraform" {
  service_principal_id = azuread_service_principal.github_actions_terraform.id
}

# Give GitHub Actions permissions to the subscription
resource "azurerm_role_assignment" "github_actions_terraform" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.github_actions_terraform.object_id
}

# Grant Application Administrator role to the Terraform service principal in Azure AD
resource "azuread_directory_role_assignment" "github_actions_terraform_app_admin" {
  role_id             = "9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3" # Application Administrator role ID
  principal_object_id = azuread_service_principal.github_actions_terraform.object_id
}

# Resource group for the Aurora infrastructure
resource "azurerm_resource_group" "aurora" {
  name     = "${var.environment}-aurora-rg"
  location = var.location
}

resource "azurerm_container_registry" "aurora" {
  name                = "acr${var.environment}aurora42" # Global unique name
  resource_group_name = azurerm_resource_group.aurora.name
  location            = var.location
  sku                 = "Standard"
}

# Create a GitHub Actions service principal for AcrPush workflow
resource "azuread_application" "github_actions_acr_push" {
  display_name = "github-actions-${var.environment}-aurora-acr-push"
}

resource "azuread_service_principal" "github_actions_acr_push" {
  client_id = azuread_application.github_actions_acr_push.client_id
}

resource "azuread_service_principal_password" "github_actions_acr_push" {
  service_principal_id = azuread_service_principal.github_actions_acr_push.id
}

# Give GitHub Actions permissions to the subscription
resource "azurerm_role_assignment" "github_actions_acr_push" {
  scope                = azurerm_container_registry.aurora.id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.github_actions_acr_push.object_id
}
