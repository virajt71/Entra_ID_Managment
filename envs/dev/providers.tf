terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.44.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "2.7.0"
    }
  }
  # backend "azurerm" {
  #   resource_group_name  = "tfstate-rg"
  #   storage_account_name = "tfstatergregergv"
  #   container_name       = "tfstate"
  #   key                  = "root/envs/dev/terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

provider "azapi" {
}
