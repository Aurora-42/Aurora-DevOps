data "azurerm_subscription" "current" {}

output "github_actions_credentials" {
  value = {
    client_id       = azuread_application.github_actions.client_id
    client_secret   = azuread_service_principal_password.github_actions.value
    subscription_id = data.azurerm_subscription.current.subscription_id
    tenant_id       = data.azurerm_subscription.current.tenant_id
  }
  sensitive = true
}
