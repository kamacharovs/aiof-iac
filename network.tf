/*
 * Networking
 * - Virtual network
 * - Subnet
 * - Network security group
 */
resource "azurerm_virtual_network" "aiof_vnet" {
  name                = "vnet-${var.location}-${var.env[terraform.workspace]}"
  location            = azurerm_resource_group.aiof_rg.location
  resource_group_name = azurerm_resource_group.aiof_rg.name
  address_space       = ["10.2.0.0/16"]

  tags = {
    env = var.env[terraform.workspace]
  }
}

resource "azurerm_subnet" "backends" {
  name                 = "backends"
  resource_group_name  = azurerm_resource_group.aiof_rg.name
  virtual_network_name = azurerm_virtual_network.aiof_vnet.name
  address_prefixes     = ["10.2.3.0/24"]

  service_endpoints = [
    "Microsoft.Sql",
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.ServiceBus"
  ]
}

resource "azurerm_subnet" "databases" {
  name                 = "databases"
  resource_group_name  = azurerm_resource_group.aiof_rg.name
  virtual_network_name = azurerm_virtual_network.aiof_vnet.name
  address_prefixes     = ["10.2.4.0/24"]
}

resource "azurerm_subnet" "aksnodes" {
  name                 = "aksnodes"
  resource_group_name  = azurerm_resource_group.aiof_rg.name
  virtual_network_name = azurerm_virtual_network.aiof_vnet.name
  address_prefixes     = ["10.2.2.0/24"]
}
/*
resource "azurerm_network_security_group" "aiof_vnet_nsg" {
  name                = "vnet-${var.location}-${var.env[terraform.workspace]}-nsg"
  location            = azurerm_resource_group.aiof_rg.location
  resource_group_name = azurerm_resource_group.aiof_rg.name

  tags = {
    env = var.env[terraform.workspace]
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
*/