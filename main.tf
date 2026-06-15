terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # SECURE REMOTE STATE BACKEND
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-mgmt"
    storage_account_name = "sttfstatemanagement2026"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    use_oidc             = true
    use_azuread_auth     = true 
  }
}

# GLOBAL PROVIDER CONFIGURATION
provider "azurerm" {
  features {}
  
  # CRITICAL: Forces all storage operations to utilize Entra ID RBAC instead of legacy Access Keys
  storage_use_azuread = true
}

# LAB INFRASTRUCTURE: RESOURCE GROUP
resource "azurerm_resource_group" "lab" {
  name     = "rg-terraform-sec-lab"
  location = "East US"
}

# LAB INFRASTRUCTURE: SECURE STORAGE ACCOUNT
resource "azurerm_storage_account" "lab_storage" {
  name                     = "stsecpracticesa2026"
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Enterprise Security Settings
  public_network_access_enabled = false
  https_traffic_only_enabled   = true
  shared_access_key_enabled     = false  

  # IN-LINE CHECOKV SUPPRESSIONS FOR THE RESOURCE
  #checkov:skip=CKV2_AZURE_33:Private endpoint not required for public learning lab
  #checkov:skip=CKV2_AZURE_41:SAS expiration policy not needed for lab demo
  #checkov:skip=CKV2_AZURE_47:Anonymous access blocked via public_network_access_enabled
  #checkov:skip=CKV2_AZURE_1:Using default Microsoft-managed keys instead of CMK for cost/simplicity
  #checkov:skip=CKV2_AZURE_38:Soft-delete not required for lab demo
}

# DYNAMIC KEY VAULT DATA ENGINE
data "azurerm_key_vault" "vault" {
  name                = "vamsrvault2026" 
  resource_group_name = "rg-terraform-state-mgmt"
}

data "azurerm_key_vault_secret" "db_password" {
  name         = "db-admin-password"
  key_vault_id = data.azurerm_key_vault.vault.id
}

# TEST SECRET OPERATION (Requires Key Vault Secrets Officer)
resource "azurerm_key_vault_secret" "example_logged_secret" {
  name         = "deployed-secret-reference"
  value        = data.azurerm_key_vault_secret.db_password.value
  key_vault_id = data.azurerm_key_vault.vault.id
}

# MASKED OUTPUT VALUE
output "database_password_status" {
  value     = data.azurerm_key_vault_secret.db_password.value
  sensitive = true 
}
