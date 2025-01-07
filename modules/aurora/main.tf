# Resource group for Aurora infrastructure
resource "azurerm_resource_group" "aurora" {
  name     = "${var.environment}-aurora-rg"
  location = var.location
}

resource "azurerm_container_registry" "aurora" {
  name                = "${var.environment}aurora42acr" # Global unique name
  resource_group_name = azurerm_resource_group.aurora.name
  location            = var.location
  sku                 = "Standard"
}

# Create a service principal with AcrPush permissions for GitHub Actions
resource "azuread_application" "github_actions_acr_push" {
  display_name = "${var.environment}-aurora-github-actions-acr-push"
}

resource "azuread_service_principal" "github_actions_acr_push" {
  client_id = azuread_application.github_actions_acr_push.client_id
}

resource "azuread_service_principal_password" "github_actions_acr_push" {
  service_principal_id = azuread_service_principal.github_actions_acr_push.id
}

resource "azurerm_role_assignment" "github_actions_acr_push" {
  scope                = azurerm_container_registry.aurora.id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.github_actions_acr_push.object_id
}
