terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.39.0"
    }

    azuread = {
      source = "hashicorp/azuread"
      version = "1.3.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret

  features {}
}


locals {
  env       = var.env[terraform.workspace]
  location  = var.location[terraform.workspace]

  env_tags = {
    env = local.env
  }

  aiof_tags = {
    env = local.env
    app = var.app
  }
}


resource "azurerm_resource_group" "aiof_rg" {
  name     = "aiof-${local.env}"
  location = local.location

  tags = local.aiof_tags
}


data "azurerm_client_config" "current_rg" {}
resource "azurerm_key_vault" "aiof_kv" {
  name                        = "aiof-${local.env}-kv"
  location                    = azurerm_resource_group.aiof_rg.location
  resource_group_name         = azurerm_resource_group.aiof_rg.name
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current_rg.tenant_id
  soft_delete_enabled         = false
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current_rg.tenant_id
    object_id = data.azurerm_client_config.current_rg.object_id

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
      "set",
      "delete",
    ]

    storage_permissions = [
      "get",
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current_rg.tenant_id
    object_id = data.azuread_user.gkamacharov.object_id

    key_permissions = [
      "list",
      "get",
      "create",
      "delete",
    ]

    secret_permissions = [
      "list",
      "get",
      "set",
      "delete",
    ]

    storage_permissions = [
      "set",
    ]
  }

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = local.env_tags
}
resource "azurerm_key_vault_secret" "kv_jwt_private_key" {
  name         = var.kv_jwt_private_key
  value        = var.appsettings_auth_jwt_private_key_value
  key_vault_id = azurerm_key_vault.aiof_kv.id

  tags = local.env_tags
}
resource "azurerm_key_vault_secret" "kv_jwt_public_key" {
  name         = var.kv_jwt_public_key
  value        = var.appsettings_auth_jwt_public_key_value
  key_vault_id = azurerm_key_vault.aiof_kv.id

  tags = local.env_tags
}


resource "azurerm_application_insights" "heimdall" {
  name                = "heimdall-${local.env}"
  location            = azurerm_resource_group.aiof_rg.location
  resource_group_name = azurerm_resource_group.aiof_rg.name
  application_type    = "web"
}


/*
Database
*/
module "database" {
  source = "./modules/database"

  location  = local.location
  env       = local.env
  env_tags  = local.env_tags

  rg = {
    location  = azurerm_resource_group.aiof_rg.location
    name      = azurerm_resource_group.aiof_rg.name
  }

  db_admin_username = var.db_admin_username
  db_admin_password = var.db_admin_password
  db_admin_start_ip = var.db_admin_start_ip
}


/*
App
*/
module "app" {
  source = "./modules/app"

  location  = local.location
  env       = local.env
  env_tags  = local.env_tags

  rg = {
    location  = azurerm_resource_group.aiof_rg.location
    name      = azurerm_resource_group.aiof_rg.name
  }

  appsettings_auth_jwt_private_key_value    = var.appsettings_auth_jwt_private_key_value
  appsettings_auth_jwt_public_key_value     = var.appsettings_auth_jwt_public_key_value
  application_insights_instrumentation_key  = azurerm_application_insights.heimdall.instrumentation_key
  database_connection_string                = module.database.database_connection_string

  depends_on = [
    azurerm_application_insights.heimdall,
    module.database
  ]
}


/*
Messaging
*/
module "messaging" {
  source    = "./modules/messaging"

  location  = local.location
  env       = local.env

  app_service_plan_id                       = module.app.aiof_app_service_plan_id

  depends_on = [
    module.app
  ]
}


/*
Eventing
*/
module "eventing" {
  source    = "./modules/eventing"

  location  = local.location
  env       = local.env

  app_service_plan_id                       = module.app.aiof_app_service_plan_id
  application_insights_instrumentation_key  = azurerm_application_insights.heimdall.instrumentation_key
  application_insights_connection_string    = azurerm_application_insights.heimdall.connection_string

  depends_on = [
    module.app
  ]
}
