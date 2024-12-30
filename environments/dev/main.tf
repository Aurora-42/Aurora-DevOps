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
