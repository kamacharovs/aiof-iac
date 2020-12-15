terraform {
  backend "azurerm" {
    resource_group_name  = "aiof-iac"
    storage_account_name = "aiofiacdev"
    container_name       = "aiofiaccd"
  }
}