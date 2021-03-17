/*
 * SQL Database
 * - PostgreSQL server
 * - PostgreSQL database
 * - Virtual network rule for DB Admin
*/
resource "azurerm_postgresql_server" "aiof_postgres_server" {
  name                = "aiof-${var.env}"
  location            = var.rg.location
  resource_group_name = var.rg.name
 
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

  tags = var.env_tags
}

resource "azurerm_postgresql_database" "aiof_postgres_db" {
  name                = "aiof"
  resource_group_name = var.rg.name
  server_name         = azurerm_postgresql_server.aiof_postgres_server.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_firewall_rule" "aiof_dbadmin_rule" {
  name                = "dbadmin"
  resource_group_name = var.rg.name
  server_name         = azurerm_postgresql_server.aiof_postgres_server.name
  start_ip_address    = var.db_admin_start_ip
  end_ip_address      = var.db_admin_start_ip
}