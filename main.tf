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

/*
Monitor
*/
module "monitor" {
  source = "./modules/monitor"

  location  = local.location
  env       = local.env

  rg = {
    location  = azurerm_resource_group.aiof_rg.location
    name      = azurerm_resource_group.aiof_rg.name
  }

  aiof_auth_hostname      = azurerm_app_service.aiof_auth.default_site_hostname
  aiof_api_hostname       = azurerm_app_service.aiof_api.default_site_hostname
  aiof_metadata_hostname  = azurerm_app_service.aiof_metadata.default_site_hostname
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
 * App Service
 */
resource "azurerm_app_service_plan" "aiof_app_service_plan" {
  name                = "aiof-${local.env}-service-plan"
  location            = azurerm_resource_group.aiof_rg.location
  resource_group_name = azurerm_resource_group.aiof_rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }

  tags = local.env_tags
}

resource "azurerm_app_service" "aiof_auth" {
  name                = "aiof-auth-${local.env}"
  location            = azurerm_resource_group.aiof_rg.location
  resource_group_name = azurerm_resource_group.aiof_rg.name
  app_service_plan_id = azurerm_app_service_plan.aiof_app_service_plan.id

  site_config {
    always_on        = false
    linux_fx_version = var.appservice_auth_version

    cors {
      allowed_origins = ["https://${azurerm_app_service.aiof_portal.default_site_hostname}", var.cors_github_io]
    }
  }

  app_settings = {
    "ApplicationInsights__InstrumentationKey" = module.monitor.application_insights_instrumentation_key
    "FeatureManagement__RefreshToken"         = "true"
    "FeatureManagement__OpenId"               = "true"
    "FeatureManagement__MemCache"             = "true"
    "Data__PostgreSQL"                        = ""
    "MemCache__Ttl"                           = "900"
    "Jwt__Expires"                            = "900"
    "Jwt__RefreshExpires"                     = "604800"
    "Jwt__Type"                               = "Bearer"
    "Jwt__Issuer"                             = "aiof:auth"
    "Jwt__Audience"                           = "aiof:auth:audience"
    "Jwt__PrivateKey"                         = var.appsettings_auth_jwt_private_key_value
    "Jwt__PublicKey"                          = var.appsettings_auth_jwt_public_key_value
    "Hash__Iterations"                        = "10000"
    "Hash__SaltSize"                          = "16"
    "Hash__KeySize"                           = "32"
    "OpenApi__Version"                        = var.open_api.version_auth
    "OpenApi__Title"                          = var.open_api.title_auth
    "OpenApi__Description"                    = var.open_api.description_auth
    "OpenApi__Contact__Name"                  = var.open_api.contact_name
    "OpenApi__Contact__Email"                 = var.open_api.contact_email
    "OpenApi__Contact__Url"                   = var.open_api.contact_url
    "OpenApi__License__Name"                  = var.open_api.license_name_auth
    "OpenApi__License__Url"                   = var.open_api.license_url_auth
  }

  connection_string {
    name  = var.postgresql_constring_name
    type  = var.postgresql_constring_type
    value = ""
  }

  tags = local.env_tags
}

resource "azurerm_app_service" "aiof_api" {
  name                = "aiof-api-${local.env}"
  location            = azurerm_resource_group.aiof_rg.location
  resource_group_name = azurerm_resource_group.aiof_rg.name
  app_service_plan_id = azurerm_app_service_plan.aiof_app_service_plan.id

  site_config {
    always_on        = false
    linux_fx_version = var.appservice_api_version

    cors {
      allowed_origins = ["https://${azurerm_app_service.aiof_portal.default_site_hostname}", var.cors_github_io]
    }
  }

  app_settings = {
    "ApplicationInsights__InstrumentationKey" = module.monitor.application_insights_instrumentation_key
    "FeatureManagement__Asset"                = "true"
    "FeatureManagement__Goal"                 = "true"
    "FeatureManagement__Liability"            = "true"
    "FeatureManagement__Account"              = "true"
    "FeatureManagement__UserDependent"        = "true"
    "Data__PostgreSQL"                        = ""
    "Jwt__Issuer"                             = "aiof:auth"
    "Jwt__Audience"                           = "aiof:auth:audience"
    "Jwt__PublicKey"                          = var.appsettings_auth_jwt_public_key_value
    "Hash__Iterations"                        = "10000"
    "Hash__SaltSize"                          = "16"
    "Hash__KeySize"                           = "32"
    "OpenApi__Version"                        = var.open_api.version_api
    "OpenApi__Title"                          = var.open_api.title_api
    "OpenApi__Description"                    = var.open_api.description_api
    "OpenApi__Contact__Name"                  = var.open_api.contact_name
    "OpenApi__Contact__Email"                 = var.open_api.contact_email
    "OpenApi__Contact__Url"                   = var.open_api.contact_url
    "OpenApi__License__Name"                  = var.open_api.license_name_api
    "OpenApi__License__Url"                   = var.open_api.license_url_api
    "RateLimit__Second"                       = "10"
    "RateLimit__Minute"                       = "120"
    "RateLimit__Hour"                         = "3600"
  }

  connection_string {
    name  = var.postgresql_constring_name
    type  = var.postgresql_constring_type
    value = ""
  }

  tags = local.env_tags
}

resource "azurerm_app_service" "aiof_metadata" {
  name                = "aiof-metadata-${local.env}"
  location            = azurerm_resource_group.aiof_rg.location
  resource_group_name = azurerm_resource_group.aiof_rg.name
  app_service_plan_id = azurerm_app_service_plan.aiof_app_service_plan.id

  site_config {
    always_on        = false
    linux_fx_version = var.appservice_metadata_version

    cors {
      allowed_origins = ["https://${azurerm_app_service.aiof_portal.default_site_hostname}", var.cors_github_io]
    }
  }

  app_settings = {
    "WEBSITES_PORT" = "80"
  }

  tags = local.env_tags
}

resource "azurerm_app_service" "aiof_portal" {
  name                = "aiof-portal-${local.env}"
  location            = azurerm_resource_group.aiof_rg.location
  resource_group_name = azurerm_resource_group.aiof_rg.name
  app_service_plan_id = azurerm_app_service_plan.aiof_app_service_plan.id

  site_config {
    always_on        = false
    linux_fx_version = var.appservice_portal_version
  }

  app_settings = {
    "WEBSITES_PORT" = "80"
    #"REACT_APP_API_ROOT"            = "http://localhost:5001"
    #"REACT_APP_API_AUTH_ROOT"       = "https://${azurerm_app_service.aiof_auth.default_site_hostname}"
    #"REACT_APP_API_METADATA_ROOT"   = "https://${azurerm_app_service.aiof_metadata.default_site_hostname}/api"
  }

  tags = local.env_tags
}

module "messaging" {
  source = "./modules/messaging"

  location  = local.location
  env       = local.env

  app_service_plan_id = azurerm_app_service_plan.aiof_app_service_plan.id
}