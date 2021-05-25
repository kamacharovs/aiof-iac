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
  name     = "aiof-messaging-${var.env}"
  location = var.location

  tags = {
    env = var.env
  }
}

resource "azurerm_servicebus_namespace" "messaging_asb" {
  name                = "aiof-messaging-sb-${var.env}"
  location            = azurerm_resource_group.messaging_rg.location
  resource_group_name = azurerm_resource_group.messaging_rg.name

  sku                 = var.messaging_sbns_sku[terraform.workspace]
  capacity            = 0
  zone_redundant      = false

  tags = {
    env = var.env
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
  name                     = "aiofmsglog${var.env}"
  location                 = azurerm_resource_group.messaging_rg.location
  resource_group_name      = azurerm_resource_group.messaging_rg.name

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"

  tags = {
    env = var.env
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
  name                     = "aiofmsg${var.env}"
  location                 = azurerm_resource_group.messaging_rg.location
  resource_group_name      = azurerm_resource_group.messaging_rg.name

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"

  tags = {
    env = var.env
  }
}

resource "azurerm_function_app" "messaging_fa" {
  name                       = "aiof-messaging-${var.env}"
  location                   = azurerm_resource_group.messaging_rg.location
  resource_group_name        = azurerm_resource_group.messaging_rg.name

  app_service_plan_id        = var.app_service_plan_id
  storage_account_name       = azurerm_storage_account.messaging_sa.name
  storage_account_access_key = azurerm_storage_account.messaging_sa.primary_access_key
  os_type                    = "linux"

  app_settings  = {
    ServiceBusConnectionString  = azurerm_servicebus_namespace.messaging_asb.default_primary_connection_string
  }
}
