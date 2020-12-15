data "terraform_remote_state" "azurerm" {
  backend = "azurerm"
  config = {
    storage_account_name = "aiofiacdev"
    container_name       = "aiofiaccd"
    key                  = "tf/terraform.tfstate"
    access_key           = var.storage_account_key
  }
}