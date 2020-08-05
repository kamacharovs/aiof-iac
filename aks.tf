/*
 * Kubernetes

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
} */