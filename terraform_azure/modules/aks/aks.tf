# define the resource group that is used throughout the cluster
resource "azurerm_resource_group" "rg-aks" {
  name = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks-vantiq" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-aks.name
  dns_prefix          = var.aks_cluster_name
  private_cluster_enabled = var.private_cluster_enabled
  role_based_access_control {
    enabled = true
  }
  kubernetes_version = var.kubernetes_version
  node_resource_group = "${var.resource_group_name}-node"

  network_profile {
      dns_service_ip     = var.dns_service_ip
      docker_bridge_cidr = var.docker_bridge_cidr
      load_balancer_sku  = var.load_balancer_sku
      network_plugin     = var.network_plugin
      network_policy     = var.network_policy
      outbound_type      = var.outbound_type
      pod_cidr           = var.pod_cidr
      service_cidr       = var.service_cidr

      # only when any of the property is set, create a "load_balance_profile" block
      dynamic "load_balancer_profile" {
        for_each = var.managed_outbound_ip_count != null || var.outbound_ip_prefix_ids != null || var.outbound_ip_address_ids != null ? list("1") : []
        content {
          managed_outbound_ip_count = var.managed_outbound_ip_count
          outbound_ip_prefix_ids = var.outbound_ip_prefix_ids
          outbound_ip_address_ids = var.outbound_ip_address_ids
        }
      }
    }

  linux_profile {
    admin_username = var.admin_username
    ssh_key {
        key_data = file(var.ssh_key)
    }
  }

  default_node_pool {
    name       = "vantiqnp"
    node_count = var.vantiq_node_pool_node_count
    vm_size    = var.vantiq_node_pool_vm_size
    vnet_subnet_id = var.aks_node_subnet_id
    availability_zones = var.availability_zones
    node_labels = {
      "vantiq.com/workload-preference" = "compute"
    }
    orchestrator_version = var.kubernetes_version
  }


  dynamic "identity" {
    for_each = var.create_service_principal == false ? list("1") : []
    content {
      type = "SystemAssigned"
    }
  }

  dynamic "service_principal" {
    for_each = var.create_service_principal != false ? list("1") : []
    content {
      client_id     = azuread_application.aks.application_id
      client_secret = azuread_service_principal_password.aks.value
    }
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.k8s.id
    }
    kube_dashboard {
      enabled = false
    }
  }
  tags = var.tags
}

/*
resource "azurerm_kubernetes_cluster_node_pool" "vantiqnp" {
  count = var.mongodb_node_pool_node_count == 0 ? 0 : 1
  name                  = "vantiqnp"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-vantiq.id
  vm_size               = var.vantiq_node_pool_vm_size
  node_count            = var.vantiq_node_pool_node_count
  vnet_subnet_id        = var.aks_node_subnet_id
  availability_zones    = var.availability_zones
  tags                  = var.tags

  node_labels = {
    "vantiq.com/workload-preference" = "compute"
  }
}
*/

resource "azurerm_kubernetes_cluster_node_pool" "mongodbnp" {
  count = var.mongodb_node_pool_node_count == 0 ? 0 : 1
  name                  = "mongodbnp"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-vantiq.id
  vm_size               = var.mongodb_node_pool_vm_size
  node_count            = var.mongodb_node_pool_node_count
  vnet_subnet_id        = var.aks_node_subnet_id
  availability_zones    = var.availability_zones
  tags                  = var.tags

  node_labels = {
    "vantiq.com/workload-preference" = "database"
  }
  orchestrator_version = var.kubernetes_version
}

resource "azurerm_kubernetes_cluster_node_pool" "userdbnp" {
  count = var.userdb_node_pool_node_count == 0 ? 0 : 1
  name                  = "userdbnp"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-vantiq.id
  vm_size               = var.userdb_node_pool_vm_size
  node_count            = var.userdb_node_pool_node_count
  vnet_subnet_id        = var.aks_node_subnet_id
  availability_zones    = var.availability_zones
  tags                  = var.tags

  node_labels = {
    "vantiq.com/workload-preference" = "userdb"
  }
  orchestrator_version = var.kubernetes_version
}

resource "azurerm_kubernetes_cluster_node_pool" "keycloaknp" {
  count = var.keycloak_node_pool_node_count == 0 ? 0 : 1
  name                  = "keycloaknp"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-vantiq.id
  vm_size               = var.keycloak_node_pool_vm_size
  node_count            = var.keycloak_node_pool_node_count
  vnet_subnet_id        = var.aks_node_subnet_id
  availability_zones    = var.availability_zones
  tags                  = var.tags

  node_labels = {
    "vantiq.com/workload-preference" = "shared"
  }
  orchestrator_version = var.kubernetes_version
}

resource "azurerm_kubernetes_cluster_node_pool" "grafananp" {
  count = var.grafana_node_pool_node_count == 0 ? 0 : 1
  name                  = "grafananp"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-vantiq.id
  vm_size               = var.grafana_node_pool_vm_size
  node_count            = var.grafana_node_pool_node_count
  vnet_subnet_id        = var.aks_node_subnet_id
  availability_zones    = var.availability_zones
  tags                  = var.tags

  node_labels = {
    "vantiq.com/workload-preference" = "influxdb"
  }
  orchestrator_version = var.kubernetes_version
}

resource "azurerm_kubernetes_cluster_node_pool" "metricsnp" {
  count = var.metrics_node_pool_node_count == 0 ? 0 : 1
  name                  = "metricsnp"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-vantiq.id
  vm_size               = var.metrics_node_pool_vm_size
  node_count            = var.metrics_node_pool_node_count
  vnet_subnet_id        = var.aks_node_subnet_id
  availability_zones    = var.availability_zones
  tags                  = var.tags

  node_labels = {
    "vantiq.com/workload-preference" = "compute"
  }
  orchestrator_version = var.kubernetes_version
}
