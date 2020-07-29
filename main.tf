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
 * - DDOS protection plan
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
  destination_port_range      = "80,443,5432"
  source_address_prefix       = var.db_admin_start_ip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.aiof_rg.name
  network_security_group_name = azurerm_network_security_group.aiof_vnet_nsg.name
}

resource "azurerm_network_ddos_protection_plan" "aiof_ddos_pp" {
  name                = "vnet-ddos-pp-${var.env}-${var.location}"
  location            = azurerm_resource_group.aiof_rg.location
  resource_group_name = azurerm_resource_group.aiof_rg.name

  tags = {
    env = var.env
  }
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
 */
resource "azurerm_container_registry" "aiof_cr" {
  name                     = "aiof${var.env}"
  resource_group_name      = azurerm_resource_group.aiof_rg.name
  location                 = azurerm_resource_group.aiof_rg.location
  sku                      = "Basic"
  admin_enabled            = false

  tags = {
    env = var.env
  }
}



/*
 * SQL Database
 * - PostgreSQL server
 * - PostgreSQL database
 * - Virtual network rule for DB Admin
 */
resource "azurerm_postgresql_server" "aiof_postgres_server" {
  name                = "aiof-${var.env}"
  location            = azurerm_resource_group.aiof_rg.location
  resource_group_name = azurerm_resource_group.aiof_rg.name
 
  administrator_login          = var.db_admin_username
  administrator_login_password = var.db_admin_password

  sku_name   = "B_Gen5_2"
  version    = "9.6"
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

resource "azurerm_postgresql_virtual_network_rule" "example" {
  name                                 = "postgresql-vnet-rule"
  resource_group_name                  = azurerm_resource_group.aiof_rg.name
  server_name                          = azurerm_postgresql_server.aiof_postgres_server.name
  subnet_id                            = azurerm_subnet.aiof_backends.id
  ignore_missing_vnet_service_endpoint = true
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
      "${var.appsettings_auth_jwt_secret_key}"            = var.appsettings_auth_jwt_secret_value
      "${var.appsettings_connection_string_database_key}" = var.appsettings_connection_string_database_value
    }
  )

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}



/*
 * Kubernetes
 */
resource "azurerm_kubernetes_cluster" "aiof_aks" {
  name                = "aiof-${var.env}"
  location            = azurerm_resource_group.aiof_rg.location
  resource_group_name = azurerm_resource_group.aiof_rg.name
  dns_prefix          = "aiof-${var.env}"
  kubernetes_version  = var.kubernetes_version
  sku_tier            = "Free"

  default_node_pool {
    name                  = "default"
    node_count            = 1
    vm_size               = "Standard_B2s"
    os_disk_size_gb       = 8
    enable_node_public_ip = true

    vnet_subnet_id  = azurerm_subnet.aiof_aksnodes.id
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    env = var.env
  }
}