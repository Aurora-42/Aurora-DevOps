terraform {
  # Backend configuration determines where Terraform stores its state files.
  # State files are used to track the current state of your infrastructure.
  # Using a backend instead of local state is essential for team collaboration.
  # Note: You must first create the resource group, storage account, and container
  #       before creating the backend configuration.
  backend "azurerm" {
    resource_group_name  = "tfstate-dev-rg"
    storage_account_name = "tfstatedevaurora42"
    container_name       = "tfstate"
    key                  = "dev/terraform.tfstate"
  }
}

module "aurora" {
    source = "../../modules/aurora"

    environment = "dev"
    location = "brazilsouth"
}

output "github_actions_terraform_apply_credentials" {
  value     = module.aurora.github_actions_terraform_apply_credentials
  sensitive = true
}

output "github_actions_acr_push_credentials" {
  value     = module.aurora.github_actions_acr_push_credentials
  sensitive = true
}
