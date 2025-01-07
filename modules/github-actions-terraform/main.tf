data "azurerm_subscription" "current" {}

# Create a service principal with Owner and Application Administrator permissions for GitHub Actions
resource "azuread_application" "github_actions_terraform" {
  display_name = "${var.environment}-aurora-github-actions-terraform"
}

resource "azuread_service_principal" "github_actions_terraform" {
  client_id = azuread_application.github_actions_terraform.client_id
}

resource "azuread_service_principal_password" "github_actions_terraform" {
  service_principal_id = azuread_service_principal.github_actions_terraform.id
}

resource "azurerm_role_assignment" "github_actions_terraform" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.github_actions_terraform.object_id
}

resource "azuread_directory_role_assignment" "github_actions_terraform_app_admin" {
  role_id             = "9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3" # Application Administrator role ID
  principal_object_id = azuread_service_principal.github_actions_terraform.object_id
}
