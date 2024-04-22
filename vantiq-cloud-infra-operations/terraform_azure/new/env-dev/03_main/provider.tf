terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.90.0"
    }
    azuread = {
      version = "=2.47.0"
    }
    random = {
      version = "=3.6.0"
    }
  }
}

provider "azurerm" {
  features {}
}
