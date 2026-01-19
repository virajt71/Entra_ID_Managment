terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

variable "subscription" {
  type = string
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription
}
