terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.39.0"
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

resource "azurerm_resource_group" "aiof_rg" {
  name     = "aiof-${var.env}"
  location = var.location

  tags = {
    env = var.env
    app = "aiof"
  }
}


/*
 * Networking
 * - Network security group with rule for IP of DB Admin
 * - Virtual network
 * - Subnet
 */
/*
resource "azurerm_network_security_group" "aiof_vnet_nsg" {
  name                = "vnet-${var.env}-${var.location}-nsg"
  location            = azurerm_resource_group.aiof_rg.location
  resource_group_name = azurerm_resource_group.aiof_rg.name

  tags = {
    env = var.env
  }
}

resource "azurerm_network_security_rule" "aiof_vnet_nsg_rule" {
  name                        = "PostgreSQLDatabaseAdminInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "5432"
  source_address_prefix       = var.db_admin_start_ip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.aiof_rg.name
  network_security_group_name = azurerm_network_security_group.aiof_vnet_nsg.name
}

resource "azurerm_virtual_network" "aiof_vnet" {
  name                = "vnet-${var.env}-${var.location}"
  location            = azurerm_resource_group.aiof_rg.location
  resource_group_name = azurerm_resource_group.aiof_rg.name
  address_space       = ["10.0.0.0/8"]

  tags = {
    env = var.env
  }
}

resource "azurerm_subnet" "aiof_backends" {
  name                 = "backends"
  resource_group_name  = azurerm_resource_group.aiof_rg.name
  virtual_network_name = azurerm_virtual_network.aiof_vnet.name
  address_prefixes     = ["10.2.3.0/24"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_subnet" "aiof_aksnodes" {
  name                 = "aksnodes"
  resource_group_name  = azurerm_resource_group.aiof_rg.name
  virtual_network_name = azurerm_virtual_network.aiof_vnet.name
  address_prefixes     = ["10.240.0.0/16"]
}
*/



data "azurerm_client_config" "current_rg" {}
resource "azurerm_key_vault" "aiof_kv" {
  name                        = "aiof-${var.env}-kv"
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
    object_id = var.gkama_object_id

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

  tags = {
    env = var.env
  }
}
resource "azurerm_key_vault_secret" "kv_jwt_private_key" {
  name         = var.kv_jwt_private_key
  value        = var.appsettings_auth_jwt_private_key_value
  key_vault_id = azurerm_key_vault.aiof_kv.id

  tags = {
    env = var.env
  }
}
resource "azurerm_key_vault_secret" "kv_jwt_public_key" {
  name         = var.kv_jwt_public_key
  value        = var.appsettings_auth_jwt_public_key_value
  key_vault_id = azurerm_key_vault.aiof_kv.id

  tags = {
    env = var.env
  }
}


/*
 * Container Registry

resource "azurerm_container_registry" "aiof_cr" {
  name                     = "aiof${var.env}"
  resource_group_name      = azurerm_resource_group.aiof_rg.name
  location                 = azurerm_resource_group.aiof_rg.location
  sku                      = "Basic"
  admin_enabled            = false

  tags = {
    env = var.env
  }
} */



/*
 * SQL Database
 * - PostgreSQL server
 * - PostgreSQL database
 * - Virtual network rule for DB Admin
 
resource "azurerm_postgresql_server" "aiof_postgres_server" {
  name                = "aiof-${var.env}"
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

  tags = {
    env = var.env
  }
}

resource "azurerm_postgresql_database" "aiof_postgres_db" {
  name                = "AIOF"
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
*/


/*
 * Application Insights
 */
resource "azurerm_application_insights" "heimdall" {
  name                = "heimdall-${var.env}"
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
}


/*
 * App Service
 */
resource "azurerm_app_service_plan" "aiof_app_service_plan" {
  name                = "aiof-${var.env}-service-plan"
  location            = azurerm_resource_group.aiof_rg.location
  resource_group_name = azurerm_resource_group.aiof_rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }

  tags = {
    env = var.env
  }
}

resource "azurerm_app_service" "aiof_auth" {
  name                = "aiof-auth-${var.env}"
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

  app_settings = merge(
    var.appservice_auth_settings,
    {
      "ApplicationInsights__InstrumentationKey" = azurerm_application_insights.heimdall.instrumentation_key
      "Jwt__PrivateKey"                         = var.appsettings_auth_jwt_private_key_value
      "Jwt__PublicKey"                          = var.appsettings_auth_jwt_public_key_value
    }
  )

  tags = {
    env = var.env
  }
}

resource "azurerm_app_service" "aiof_api" {
  name                = "aiof-api-${var.env}"
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

  app_settings = merge(
    var.appservice_api_settings,
    {
      "ApplicationInsights__InstrumentationKey" = azurerm_application_insights.heimdall.instrumentation_key
      "Jwt__PublicKey"                          = var.appsettings_auth_jwt_public_key_value
    }
  )

  tags = {
    env = var.env
  }
}

resource "azurerm_app_service" "aiof_metadata" {
  name                = "aiof-metadata-${var.env}"
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

  tags = {
    env = var.env
  }
}
resource "azurerm_app_service" "aiof_portal" {
  name                = "aiof-portal-${var.env}"
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

  tags = {
    env = var.env
  }
}

