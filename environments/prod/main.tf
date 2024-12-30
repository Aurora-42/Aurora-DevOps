terraform {
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

module "aurora" {
    source = "../../modules/aurora"

    environment = "prod"
    location = "brazilsouth"
}
