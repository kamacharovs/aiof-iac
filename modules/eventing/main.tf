/*
Eventing
- Resource group
- Service bus namespace
- Service bus topic - sender
- Service bus topic subscription - assets
- Service bus topic subscription rule - assets
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

resource "azurerm_servicebus_topic" "eventing_asb_sender_topic" {
  name                = "sender-topic"
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

resource "azurerm_servicebus_subscription" "eventing_asb_sender_topic_asset_sub" {
  name                = "assets"
  resource_group_name = azurerm_resource_group.eventing_rg.name
  namespace_name      = azurerm_servicebus_namespace.eventing_asb.name
  topic_name          = azurerm_servicebus_topic.eventing_asb_sender_topic.name

  max_delivery_count    = 3
  default_message_ttl   = "P14D"
  lock_duration         = "PT30S"

  dead_lettering_on_message_expiration  = false
  enable_batched_operations             = false
  requires_session                      = false
}
resource "azurerm_servicebus_subscription_rule" "eventing_asb_sender_topic_asset_sub_rule" {
  name                = "assets"
  resource_group_name = azurerm_resource_group.eventing_rg.name
  namespace_name      = azurerm_servicebus_namespace.eventing_asb.name
  topic_name          = azurerm_servicebus_topic.eventing_asb_sender_topic.name
  subscription_name   = azurerm_servicebus_subscription.eventing_asb_sender_topic_asset_sub.name

  filter_type         = "SqlFilter"
  sql_filter          = "eventType like 'Asset%'"
}