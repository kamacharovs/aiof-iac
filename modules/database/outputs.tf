output "server_name" {
    value       = azurerm_postgresql_server.aiof_postgres_server.fqdn
    description = "Server name"
}

output "database_name" {
    value       = azurerm_postgresql_database.aiof_postgres_db.name
    description = "Database name"
}

output "database_connection_string" {
  value       = "Server=${var.server_name};Database=${azurerm_postgresql_database.aiof_postgres_db.name};Port=5432;User Id=${var.db_admin_username}@${azurerm_postgresql_database.aiof_postgres_db.name};Password=${var.db_admin_password};Ssl Mode=Require;"
  description = "Database connection string"
}