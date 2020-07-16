variable subscription_id {}
variable tenant_id {}
variable client_id {}
variable client_secret {}
variable location {}
variable env {}

variable db_admin_username {}
variable db_admin_password {}


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


resource "azurerm_postgresql_server" "aiof_postgres_server" {
  name                = "aiof-${var.env}"
  location            = azurerm_resource_group.aiof_rg.location
  resource_group_name = azurerm_resource_group.aiof_rg.name
 
  administrator_login          = var.db_admin_username
  administrator_login_password = var.db_admin_password

  sku_name   = "B_Gen5_2"
  version    = "9.5"
  storage_mb = 5120

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = false

  public_network_access_enabled    = true
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

  tags = {
    env = var.env
  }
}

resource "azurerm_postgresql_database" "example" {
  name                = "AIOF"
  resource_group_name = azurerm_resource_group.aiof_rg.name
  server_name         = azurerm_postgresql_server.aiof_postgres_server.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}