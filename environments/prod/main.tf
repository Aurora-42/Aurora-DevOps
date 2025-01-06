terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.14.0"
    }
  }

  # Backend configuration determines where Terraform stores its state files.
  # State files are used to track the current state of your infrastructure.
  # Using a backend instead of local state is essential for team collaboration.
  # Note: You must first create the resource group, storage account, and container
  #       before creating the backend configuration.
  backend "azurerm" {
    resource_group_name  = "tfstate-prod-rg"
    storage_account_name = "tfstateprodaurora42"
    container_name       = "tfstate"
    key                  = "prod/terraform.tfstate"
  }
}

module "tfstate" {
  source = "../../modules/tfstate"

  environment = "prod"
  location = "brazilsouth"
}

module "aurora" {
  source = "../../modules/aurora"

  environment = "prod"
  location = "brazilsouth"
}

output "github_actions_terraform_credentials" {
  value     = module.aurora.github_actions_terraform_credentials
  sensitive = true
}

output "github_actions_acr_push_credentials" {
  value     = module.aurora.github_actions_acr_push_credentials
  sensitive = true
}
