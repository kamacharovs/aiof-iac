terraform {
  backend "azurerm" {
    resource_group_name  = "aiof-iac"
    storage_account_name = "aiofiacdev"
    container_name       = "aiofiaccd"
    key                  = "tf/terraform.tfstate"

    # Do not set access_key here. Please set a command line variable TF_VAR_storage_account_access_key
  }
}