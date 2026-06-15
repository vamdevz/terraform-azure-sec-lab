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

  # FIXES CRITICAL FLAWS:
  public_network_access_enabled = false    # fixed security flagged by checkov
  https_traffic_only_enabled   = true     # fixed security flagged by checkov

  # CHECOKV SUPPRESSIONS FOR LAB ENVIRONMENT:
  #checkov:skip=CKV2_AZURE_33:Private endpoint not required for public learning lab
  #checkov:skip=CKV2_AZURE_41:SAS expiration policy not needed for lab demo
  #checkov:skip=CKV2_AZURE_47:Anonymous access blocked via public_network_access_enabled
  #checkov:skip=CKV2_AZURE_1:Using default Microsoft-managed keys instead of CMK for cost/simplicity
}