provider "azurerm" {
 version = "~> 2.19.0"

 subscription_id = var.subscription_id
 tenant_id = var.tenant_id
 client_id = var.client_id
 client_secret = var.client_secret

 features {}
}

resource "azurerm_resource_group" "aiof_rg" {
  name     = "aiof-${var.env}"
  location = var.location
  
  tags = {
    env = var.env
  }
}


/*
 * Networking
 * - Network security group with rule for IP of DB Admin
 * - Virtual network
 * - Subnet
 */
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

  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.aiof_ddos_pp.id
    enable = true
  }

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
    always_on                = false
    linux_fx_version         = var.appservice_version

    cors {
      allowed_origins        = ["*"]
    }
  }

  app_settings = merge(
    var.appservice_auth_settings,
    {
      "${var.appsettings_auth_jwt_secret_key}"    = var.appsettings_auth_jwt_secret_value
      "${var.appsettings_auth_jwt_private_key}"   = var.appsettings_auth_jwt_private_key_value
      "${var.appsettings_auth_jwt_public_key}"    = var.appsettings_auth_jwt_public_key_value
    }
  )
}
