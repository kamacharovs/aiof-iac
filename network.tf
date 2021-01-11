/*
 * Networking
 * - Network security group with rule for IP of DB Admin
 * - Virtual network
 * - Subnet
 */
/*
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
*/