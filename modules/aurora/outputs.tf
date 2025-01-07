data "azurerm_subscription" "current" {}

# This credentials are used by the GitHub Actions workflow to push images to the Azure Container Registry
output "github_actions_acr_push_credentials" {
  value = {
    client_id     = azuread_service_principal.github_actions_acr_push.client_id
    client_secret = azuread_service_principal_password.github_actions_acr_push.value
    subscription_id = data.azurerm_subscription.current.subscription_id
    tenant_id       = data.azurerm_subscription.current.tenant_id
  }
  sensitive = true
}

output "container_registry_name" {
  value = azurerm_container_registry.aurora.name
}
