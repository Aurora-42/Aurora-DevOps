terraform {
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

  # Backend configuration determines where Terraform stores its state files.
  # State files are used to track the current state of your infrastructure.
  # Using a backend instead of local state is essential for team collaboration.
  # Note: You must first create the resource group, storage account, and container
  #       before creating the backend configuration.
  backend "azurerm" {
    resource_group_name  = "tfstate-prod-aurora-rg"
    storage_account_name = "tfstateprodaurora42"
    container_name       = "tfstate"
    key                  = "prod/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

module "tfstate" {
  source = "../../modules/tfstate"

  environment = var.environment
  location    = var.location
}

module "github_actions_terraform" {
  source = "../../modules/github-actions-terraform"

  environment = var.environment
}

module "aurora" {
  source = "../../modules/aurora"

  environment = var.environment
  location    = var.location
}
