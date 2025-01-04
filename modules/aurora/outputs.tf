data "azurerm_subscription" "current" {}

output "github_actions_terraform_apply_credentials" {
  value = {
    client_id       = azuread_application.github_actions_terraform_apply.client_id
    client_secret   = azuread_service_principal_password.github_actions_terraform_apply.value
    subscription_id = data.azurerm_subscription.current.subscription_id
    tenant_id       = data.azurerm_subscription.current.tenant_id
  }
  sensitive = true
}

output "github_actions_acr_push_credentials" {
  value = {
    client_id       = azuread_application.github_actions_acr_push.client_id
    client_secret   = azuread_service_principal_password.github_actions_acr_push.value
    subscription_id = data.azurerm_subscription.current.subscription_id
    tenant_id       = data.azurerm_subscription.current.tenant_id
  }
  sensitive = true
}
