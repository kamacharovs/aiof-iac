output "database_connection_string" {
  value       = "Server=${azurerm_postgresql_server.aiof_postgres_server.fqdn};Database=${azurerm_postgresql_database.aiof_postgres_db.name};Port=5432;User Id=${var.db_admin_username};Password=${var.db_admin_password};Ssl Mode=Require;"
  description = "Database connection string"
}