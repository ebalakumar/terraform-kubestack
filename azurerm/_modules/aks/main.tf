resource "azurerm_resource_group" "current" {
  name     = "${var.metadata_name}"
  location = "${var.location}"
}

resource "azurerm_log_analytics_workspace" "current" {
  name                = "${var.metadata_name}"
  location            = "${azurerm_resource_group.current.location}"
  resource_group_name = "${azurerm_resource_group.current.name}"
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "current" {
  solution_name         = "ContainerInsights"
  location              = "${azurerm_resource_group.current.location}"
  resource_group_name   = "${azurerm_resource_group.current.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.current.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.current.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_kubernetes_cluster" "current" {
  name                = "${var.metadata_name}"
  location            = "${azurerm_resource_group.current.location}"
  resource_group_name = "${azurerm_resource_group.current.name}"
  dns_prefix          = "acctestagent1"

  agent_pool_profile {
    name            = "default"
    count           = "${var.agent_pool_profile_count}"
    vm_size         = "${var.agent_pool_profile_vm_size}"         # "Standard_D1_v2"
    os_type         = "${var.agent_pool_profile_os_type}"         # "Linux"
    os_disk_size_gb = "${var.agent_pool_profile_os_disk_size_gb}" # 30
  }

  service_principal {
    client_id     = "00000000-0000-0000-0000-000000000000"
    client_secret = "00000000000000000000000000000000"
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = "${azurerm_log_analytics_workspace.current.id}"
    }
  }

  tags = "${var.metadata_labels}"
}
