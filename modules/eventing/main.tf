/*
Eventing
- Resource group
- Service bus namespace
- Service bus topic - emitter
- Service bus topic subscription - assets
- Service bus topic subscription rule - assets
- Storage account
*/
resource "azurerm_resource_group" "eventing_rg" {
  name     = "aiof-eventing-${var.env}"
  location = var.location

  tags = {
    env = var.env
  }
}

resource "azurerm_servicebus_namespace" "eventing_asb" {
  name                = "aiof-eventing-${var.env}"
  location            = azurerm_resource_group.eventing_rg.location
  resource_group_name = azurerm_resource_group.eventing_rg.name
  sku                 = "Standard"

  tags = {
    env = var.env
  }
}

resource "azurerm_servicebus_topic" "eventing_asb_emitter_topic" {
  name                = "emitter-topic"
  resource_group_name = azurerm_resource_group.eventing_rg.name
  namespace_name      = azurerm_servicebus_namespace.eventing_asb.name

  max_size_in_megabytes = 1024
  default_message_ttl   = "P14D"

  enable_partitioning           = false
  enable_batched_operations     = false
  enable_express                = false
  requires_duplicate_detection  = false
  support_ordering              = false
}

resource "azurerm_servicebus_subscription" "eventing_asb_emitter_topic_asset_sub" {
  name                = "assets"
  resource_group_name = azurerm_resource_group.eventing_rg.name
  namespace_name      = azurerm_servicebus_namespace.eventing_asb.name
  topic_name          = azurerm_servicebus_topic.eventing_asb_emitter_topic.name

  max_delivery_count    = 3
  default_message_ttl   = "P14D"
  lock_duration         = "PT30S"

  dead_lettering_on_message_expiration  = false
  enable_batched_operations             = false
  requires_session                      = false
}
resource "azurerm_servicebus_subscription_rule" "eventing_asb_emitter_topic_asset_sub_rule" {
  name                = "assets"
  resource_group_name = azurerm_resource_group.eventing_rg.name
  namespace_name      = azurerm_servicebus_namespace.eventing_asb.name
  topic_name          = azurerm_servicebus_topic.eventing_asb_emitter_topic.name
  subscription_name   = azurerm_servicebus_subscription.eventing_asb_emitter_topic_asset_sub.name

  filter_type         = "SqlFilter"
  sql_filter          = "eventtype in ('AssetAdded', 'AssetUpdated', 'AssetDeleted')"
}

resource "azurerm_storage_account" "eventing_emitter_sa" {
  name                     = "aiofeventingemitter${var.env}"
  location                 = azurerm_resource_group.eventing_rg.location
  resource_group_name      = azurerm_resource_group.eventing_rg.name

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"

  tags = {
    env = var.env
  }
}

resource "azurerm_storage_table" "eventing_emitter_sa_table_config" {
  name                 = "EmitterConfig"
  storage_account_name = azurerm_storage_account.eventing_emitter_sa.name
}
resource "azurerm_storage_table" "eventing_emitter_sa_table_log" {
  name                 = "EventLog"
  storage_account_name = azurerm_storage_account.eventing_emitter_sa.name
}

resource "azurerm_function_app" "eventing_emitter_fa" {
  name                       = "aiof-eventing-emitter-${var.env}"
  location                   = azurerm_resource_group.eventing_rg.location
  resource_group_name        = azurerm_resource_group.eventing_rg.name

  app_service_plan_id        = var.app_service_plan_id
  storage_account_name       = azurerm_storage_account.eventing_emitter_sa.name
  storage_account_access_key = azurerm_storage_account.eventing_emitter_sa.primary_access_key
  os_type                    = "linux"

  app_settings  = {
    FUNCTIONS_WORKER_RUNTIME              = "dotnet"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE   = "true"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE       = "true"
    APPINSIGHTS_INSTRUMENTATIONKEY        = var.application_insights_instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.application_insights_connection_string
    StorageConnectionString               = azurerm_storage_account.eventing_emitter_sa.primary_connection_string
    ServiceBusConnection                  = azurerm_servicebus_namespace.eventing_asb.default_primary_connection_string
    EmitterTopicName                      = azurerm_servicebus_topic.eventing_asb_emitter_topic.name
    EmitterConfigTableName                = azurerm_storage_table.eventing_emitter_sa_table_config.name
    EmitterLogTableName                   = azurerm_storage_table.eventing_emitter_sa_table_log.name
  }
}

data "azurerm_function_app_host_keys" "eventing_emitter_fa_host_keys" {
  name                = azurerm_function_app.eventing_emitter_fa.name
  resource_group_name = azurerm_resource_group.eventing_rg.name
}