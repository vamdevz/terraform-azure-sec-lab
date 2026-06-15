terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-mgmt"
    storage_account_name = "sttfstatemanagement2026"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    use_oidc             = true
    
    # CORRECTED TYPO HERE:
    use_azuread_auth     = true 
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
  name                     = "stsecpracticesa2026"
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  public_network_access_enabled = true   
  https_traffic_only_enabled   = false  
}

# Data block to read the existing Key Vault
data "azurerm_key_vault" "vault" {
  name                = "vamsrvault2026" # Must match your vault name
  resource_group_name = "rg-terraform-state-mgmt"
}

# Data block to fetch the specific secret dynamically
data "azurerm_key_vault_secret" "db_password" {
  name         = "db-admin-password"
  key_vault_id = data.azurerm_key_vault.vault.id
}

# Example resource utilizing the secret securely
resource "azurerm_key_vault_secret" "example_logged_secret" {
  name         = "deployed-secret-reference"
  value        = data.azurerm_key_vault_secret.db_password.value
  key_vault_id = data.azurerm_key_vault.vault.id
}

output "database_password_status" {
  value     = data.azurerm_key_vault_secret.db_password.value
  sensitive = true 
}
