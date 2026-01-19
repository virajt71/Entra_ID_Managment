terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatergrege33rgv"
    container_name       = "tfstate"
    key                  = "root/sub_managment/groups/terraform.tfstate"
  }
}

variable "subscription" {
  type = string
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription
}
