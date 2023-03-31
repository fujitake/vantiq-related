# provider "azurerm" {
#   features {}
# }

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.87.0"
    }
    azuread = {
      version = "=2.11.0"
    }
    random = {
      version = "~>3.1.0"
    }
  }
}

locals {
  tf_remote_backend = {
    resource_group_name  = "<INPUT-YOUR-RESOURCE-GROUP>"
    storage_account_name = "<INPUT-YOUR-STORAGE-ACCOUNT>"
    container_name       = "<INPUT-YOUR-CONTAINER-NAME>"
  }
}

locals {
  common_config = {
    vantiq_cluster_name      = "vantiq"
    env_name                 = "prod"
    location                 = "japaneast"
    cluster_version          = "1.24.9"
    opnode_kubectl_version   = "1.24.9"
    opnode_jdk_version       = "11"
    ssh_private_key_aks_node = "aks_node_id_rsa"
    ssh_public_key_aks_node  = "aks_node_id_rsa.pub"
    ssh_public_key_opnode    = "opnode_id_rsa.pub"
  }
}

locals {
  network_config = {
    vnet_address_cidr = ["10.1.0.0/16"]
    vnet_dns_servers  = null # default
    #  vnet_dns_servers =  ["XX.X.X.3", "XX.X.X.4"]
    snet_aks_node_address_cidr = ["10.1.48.0/20"]
    snet_aks_lb_address_cidr   = ["10.1.1.128/25"]
    snet_op_address_cidr       = ["10.1.2.0/27"]
    # network security groups
    # amqps : TCP 5671
    # mqtt : 1883, 8883, 12470 (ws), 12473 (wss)
    # git : TCP 9418
    # https: TCP 443
    # kafka : TCP 9092, 8083
    # dns : TCP 53
    # smtp: 25, 587

    snet_aks_allow_inbound_cidr  = ["10.0.0.0/8"] # replace with more stricted cidr
    snet_aks_allow_outbound_port = "*"
    #  snet_aks_allow_outbound_ports = ["25", "443", "587", "9418", "1883", "8883", "12470", "12473", "9092", "8083"] # smtp, https, smtps, git, mqtts, amqps,kafka

    snet_op_allow_inbound_cidr  = ["10.0.0.0/8"] # replace with more stricted cidr
    snet_op_allow_outbound_port = "*"
    #  snet_op_allow_outbound_ports = ["25", "443", "587", "9418", "80"]   # smtp, https, smtps, git, http

    snet_lb_allow_inbound_cidr = ["10.0.0.0/8"] # replace with more stricted cidr

    # vnet-peering. use if vnet ids are already known
    vnet_peering_remote_vnet_ids = []

  }
}

locals {
  opnode_config = {
    opnode_host_name   = "opnode-1"
    opnode_user_name   = "system"
    ssh_access_enabled = true
    ssh_public_key     = local.common_config.ssh_public_key_opnode # required if ssh_access_enabled = true
    #  opnode_password = "EventDriven6"      # required if ssh_access_enabled = false
    opnode_vm_size = "Standard_B1ms"
    #  ssh_access_enabled = true

    # Temporarily allow public access until expressroute is available
    public_ip_enabled = true
    domain_name_label = "${local.common_config.vantiq_cluster_name}-${local.common_config.env_name}"
    vm_backup_enabled = true

    # used for set up opnode
    ssh_private_key_aks_node = local.common_config.ssh_private_key_aks_node
  }
}


locals {
  rdb_config = {
    public_network_access_enabled = false
  }
}

locals {
  aks_config = {
    # fixed parameter. Do not change.

    # kubernetes version
    kubernetes_version = local.common_config.cluster_version

    # enable private cluster
    private_cluster_enabled = false

    # enable container insights + loganalytics
    loganalytics_enabled = false

    # netowrk profile - required. may be variable for each client
    service_cidr   = "10.1.1.0/25"
    dns_service_ip = "10.1.1.10"

    # network profile (optional)
    docker_bridge_cidr = "172.17.0.1/16"
    #  load_balancer_sku = "standard"
    #  network_plugin = "kubenet"
    #  network_policy = "calico"
    #  outbound_type = "loadBalancer"
    #  pod_cidr = "172.18.0.0/16"

    # load balancer profile (option)
    # managed_outbound_ip_count = 1
    # outbound_ip_prefix_ids = ["xxx.xxx.xxx.xxx/x"]
    # outbound_ip_address_ids = ["xxx.xxx.xxx.xxx", "xxx.xxx.xxx.xxx"]

    # linux profile
    admin_username = "ubuntu"
    ssh_key        = local.common_config.ssh_public_key_aks_node

    # node pool
    # "Standard_F4s_v2 (4vCPU + 8GiB) - equivalent to C5.xlarge
    # "Standard_E4s_v3" (4vCPU + 32GiB) - equivalent to R5.xlarge
    # "Standard_B2S" (2vCPU + 4GiB)- equivalent to T3.medium
    # "Standard_E2_v3" (4vCPU + 32GiB) -  equivalent to M5.large
    availability_zones                        = [1, 2, 3]
    vantiq_node_pool_vm_size                  = "Standard_F4s_v2"
    vantiq_node_pool_node_count               = 3
    vantiq_node_pool_node_ephemeral_os_disk   = true
    mongodb_node_pool_vm_size                 = "Standard_E4s_v3"
    mongodb_node_pool_node_count              = 3
    mongodb_node_pool_node_ephemeral_os_disk  = true
    userdb_node_pool_vm_size                  = "Standard_E4s_v3"
    userdb_node_pool_node_count               = 0
    userdb_node_pool_node_ephemeral_os_disk   = true
    grafana_node_pool_vm_size                 = "Standard_E4s_v3"
    grafana_node_pool_node_count              = 1
    grafana_node_pool_node_ephemeral_os_disk  = true
    keycloak_node_pool_vm_size                = "Standard_B2S"
    keycloak_node_pool_node_count             = 3
    keycloak_node_pool_node_ephemeral_os_disk = false
    metrics_node_pool_vm_size                 = "Standard_F4s_v2"
    metrics_node_pool_node_count              = 1
    metrics_node_pool_node_ephemeral_os_disk  = true
  }
}

locals {
  backup_storage_config = {
    delete_after_days_since_modification_greater_than = 3
  }
}