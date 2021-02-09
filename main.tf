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

provider "azuread" {
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
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
resource "azurerm_container_registry" "aiof_cr" {
  name                     = "aiof${local.env}"
  resource_group_name      = azurerm_resource_group.aiof_rg.name
  location                 = azurerm_resource_group.aiof_rg.location
  sku                      = "Basic"
  admin_enabled            = false

  tags = local.aiof_tags
}
*/


/*
 * SQL Database
 * - PostgreSQL server
 * - PostgreSQL database
 * - Virtual network rule for DB Admin
*/
resource "azurerm_postgresql_server" "aiof_postgres_server" {
  name                = "aiof-${local.env}"
  location            = azurerm_resource_group.aiof_rg.location
  resource_group_name = azurerm_resource_group.aiof_rg.name
 
  administrator_login          = var.db_admin_username
  administrator_login_password = var.db_admin_password

  sku_name   = var.postgresql_sku_name
  version    = var.postgresql_version
  storage_mb = 5120

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = false

  public_network_access_enabled    = true
  ssl_enforcement_enabled          = false

  tags = local.env_tags
}

resource "azurerm_postgresql_database" "aiof_postgres_db" {
  name                = "aiof"
  resource_group_name = azurerm_resource_group.aiof_rg.name
  server_name         = azurerm_postgresql_server.aiof_postgres_server.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_firewall_rule" "aiof_dbadmin_rule" {
  name                = "dbadmin"
  resource_group_name = azurerm_resource_group.aiof_rg.name
  server_name         = azurerm_postgresql_server.aiof_postgres_server.name
  start_ip_address    = var.db_admin_start_ip
  end_ip_address      = var.db_admin_start_ip
}


/*
 * Application Insights
 */
resource "azurerm_application_insights" "heimdall" {
  name                = "heimdall-${local.env}"
  location            = azurerm_resource_group.aiof_rg.location
  resource_group_name = azurerm_resource_group.aiof_rg.name
  application_type    = var.application_insights_application_type
}

resource "azurerm_application_insights_web_test" "heimdall-aiof-auth-health" {
  name                    = "aiof-auth-health"
  location                = azurerm_resource_group.aiof_rg.location
  resource_group_name     = azurerm_resource_group.aiof_rg.name
  application_insights_id = azurerm_application_insights.heimdall.id
  kind                    = "ping"
  frequency               = 300
  timeout                 = 120
  enabled                 = true
  geo_locations           = ["us-ca-sjc-azr", "us-tx-sn1-azr", "us-il-ch1-azr", "us-va-ash-azr", "us-fl-mia-edge"]

  configuration = <<XML
  <WebTest Name="aiof-auth-health" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="120" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
    <Items>
      <Request Method="GET" Version="1.1" Url="https://${azurerm_app_service.aiof_auth.default_site_hostname}/health" ThinkTime="0" Timeout="120" ParseDependentRequests="False" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False"/>
    </Items>
  </WebTest>
  XML

  tags = {
    "hidden-link:/subscriptions/ca878169-d059-41cb-a0f0-d2e714ea53b5/resourceGroups/aiof-dev/providers/microsoft.insights/components/heimdall-dev" = "Resource"
  }
}
resource "azurerm_application_insights_web_test" "heimdall-aiof-api-health" {
  name                    = "aiof-api-health"
  location                = azurerm_resource_group.aiof_rg.location
  resource_group_name     = azurerm_resource_group.aiof_rg.name
  application_insights_id = azurerm_application_insights.heimdall.id
  kind                    = "ping"
  frequency               = 300
  timeout                 = 120
  enabled                 = true
  geo_locations           = ["us-ca-sjc-azr", "us-tx-sn1-azr", "us-il-ch1-azr", "us-va-ash-azr", "us-fl-mia-edge"]

  configuration = <<XML
  <WebTest Name="aiof-auth-health" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="120" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
    <Items>
      <Request Method="GET" Version="1.1" Url="https://${azurerm_app_service.aiof_api.default_site_hostname}/health" ThinkTime="0" Timeout="120" ParseDependentRequests="False" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False"/>
    </Items>
  </WebTest>
  XML

  tags = {
    "hidden-link:/subscriptions/ca878169-d059-41cb-a0f0-d2e714ea53b5/resourceGroups/aiof-dev/providers/microsoft.insights/components/heimdall-dev" = "Resource"
  }
}
resource "azurerm_application_insights_web_test" "heimdall-aiof-metadata-health" {
  name                    = "aiof-metadata-health"
  location                = azurerm_resource_group.aiof_rg.location
  resource_group_name     = azurerm_resource_group.aiof_rg.name
  application_insights_id = azurerm_application_insights.heimdall.id
  kind                    = "ping"
  frequency               = 300
  timeout                 = 120
  enabled                 = true
  geo_locations           = ["us-ca-sjc-azr", "us-tx-sn1-azr", "us-il-ch1-azr", "us-va-ash-azr", "us-fl-mia-edge"]

  configuration = <<XML
  <WebTest Name="aiof-metadata-health" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="120" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
    <Items>
      <Request Method="GET" Version="1.1" Url="https://${azurerm_app_service.aiof_metadata.default_site_hostname}/health" ThinkTime="0" Timeout="120" ParseDependentRequests="False" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False"/>
    </Items>
  </WebTest>
  XML

  tags = {
    "hidden-link:/subscriptions/ca878169-d059-41cb-a0f0-d2e714ea53b5/resourceGroups/aiof-dev/providers/microsoft.insights/components/heimdall-dev" = "Resource"
  }
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

/*resource "azurerm_app_service" "aiof_data" {
  name                = "aiof-data-${local.env}"
  location            = azurerm_resource_group.aiof_rg.location
  resource_group_name = azurerm_resource_group.aiof_rg.name
  app_service_plan_id = azurerm_app_service_plan.aiof_app_service_plan.id

  site_config {
    always_on        = false
    linux_fx_version = var.appservice_data_version
  }

  app_settings = {
    "WEBSITES_PORT" = "80"
  }

  tags = local.env_tags
}*/

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
    "ApplicationInsights__InstrumentationKey" = azurerm_application_insights.heimdall.instrumentation_key
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
    "ApplicationInsights__InstrumentationKey" = azurerm_application_insights.heimdall.instrumentation_key
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


/*
Messaging service
- Resource group
- Service bus namespace
- Service bus queues
- Storage account (function app)
- Storage account (log)
- Function app
*/
resource "azurerm_resource_group" "messaging_rg" {
  name     = "aiof-messaging-${local.env}"
  location = local.location

  tags = {
    env = local.env
    app = var.messaging_app
  }
}

resource "azurerm_servicebus_namespace" "messaging_asb" {
  name                = "aiof-messaging-sb-${local.env}"
  location            = azurerm_resource_group.messaging_rg.location
  resource_group_name = azurerm_resource_group.messaging_rg.name

  sku                 = var.messaging_sbns_sku[terraform.workspace]
  capacity            = 0
  zone_redundant      = false

  tags = {
    env = local.env
    app = var.messaging_app
  }
}

resource "azurerm_servicebus_queue" "messaging_asbq_inbound" {
  name                = "inbound"
  resource_group_name = azurerm_resource_group.messaging_rg.name
  namespace_name      = azurerm_servicebus_namespace.messaging_asb.name

  max_size_in_megabytes = 1024
  lock_duration         = "PT1M"
  default_message_ttl   = "PT10M"
  max_delivery_count    = 3

  enable_batched_operations     = true
  requires_duplicate_detection  = false
  enable_partitioning           = false
  requires_session              = false
}

resource "azurerm_servicebus_queue" "messaging_asbq_email" {
  name                = "email"
  resource_group_name = azurerm_resource_group.messaging_rg.name
  namespace_name      = azurerm_servicebus_namespace.messaging_asb.name

  max_size_in_megabytes = 1024
  lock_duration         = "PT1M"
  default_message_ttl   = "PT10M"
  max_delivery_count    = 3

  enable_batched_operations     = true
  requires_duplicate_detection  = false
  enable_partitioning           = false
  requires_session              = false
}

resource "azurerm_storage_account" "messaging_log_sa" {
  name                     = "aiofmsglog${local.env}"
  location                 = azurerm_resource_group.messaging_rg.location
  resource_group_name      = azurerm_resource_group.messaging_rg.name

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"

  tags = {
    env = local.env
    app = var.messaging_app
  }
}
resource "azurerm_storage_table" "messaging_inboundsa_table" {
  name                 = "inbound"
  storage_account_name = azurerm_storage_account.messaging_log_sa.name
}
resource "azurerm_storage_table" "messaging_email_sa_table" {
  name                 = "email"
  storage_account_name = azurerm_storage_account.messaging_log_sa.name
}
resource "azurerm_storage_table" "messaging_deadletter_sa_table" {
  name                 = "deadletter"
  storage_account_name = azurerm_storage_account.messaging_log_sa.name
}

resource "azurerm_storage_account" "messaging_sa" {
  name                     = "aiofmsg${local.env}"
  location                 = azurerm_resource_group.messaging_rg.location
  resource_group_name      = azurerm_resource_group.messaging_rg.name

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"

  tags = {
    env = local.env
    app = var.messaging_app
  }
}

resource "azurerm_function_app" "messaging-fa" {
  name                       = "aiof-messaging-${local.env}"
  location                   = azurerm_resource_group.messaging_rg.location
  resource_group_name        = azurerm_resource_group.messaging_rg.name

  app_service_plan_id        = azurerm_app_service_plan.aiof_app_service_plan.id
  storage_account_name       = azurerm_storage_account.messaging_sa.name
  storage_account_access_key = azurerm_storage_account.messaging_sa.primary_access_key
  os_type                    = "linux"

  app_settings  = {
    ServiceBusConnectionString  = azurerm_servicebus_namespace.messaging_asb.default_primary_connection_string
  }
}
