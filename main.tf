terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "lab" {
  name     = "rg-terraform-sec-lab"
  location = "East US"
}

resource "azurerm_storage_account" "lab_storage" {
  name                     = "stsecpracticesa2026" # Must be globally unique
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # SECURITY FLAWS FOR CHECKOV TO CATCH:
  public_network_access_enabled = true   # Checkov will flag this as too open
  https_traffic_only_enabled   = false  # Checkov will flag this (unencrypted traffic allowed)
}