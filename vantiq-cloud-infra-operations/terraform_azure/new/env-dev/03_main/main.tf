data "azurerm_subscription" "current" {}

module "constants" {
  source = "../"
}

locals {
  vantiq_cluster_name = module.constants.common_config.vantiq_cluster_name
  env_name            = module.constants.common_config.env_name
  location            = module.constants.common_config.location
}

###
###  RDB
###
module "rdb" {
  # fixed parameter. Do not change.
  source              = "../../modules/rdb"
  vantiq_cluster_name = local.vantiq_cluster_name
  location            = local.location
  resource_group_name = "rg-${local.vantiq_cluster_name}-${local.env_name}-rdb"

  db_server_name                = replace(lower("keycloak${local.vantiq_cluster_name}${local.env_name}"), "/[^-a-z0-9]/", "")
  public_network_access_enabled = module.constants.rdb_config.public_network_access_enabled
  tags = {
    environment = local.env_name
    app         = local.vantiq_cluster_name
  }

  #  private_endpoint_vnet_ids = data.terraform_remote_state.network.outputs.vnet_id, data.terraform_remote_state.network.outputs.vnet_svc_id]
  private_endpoint_vnet_ids = [data.terraform_remote_state.network.outputs.vpc_vnet_id]
  private_subnet_id         = data.terraform_remote_state.network.outputs.vpc_snet_aks_node_id
}

###
###  AKS
###
module "aks" {
  # fixed parameter. Do not change.
  source              = "../../modules/aks"
  aks_cluster_name    = replace("aks-${local.vantiq_cluster_name}-${local.env_name}", "/[^-a-zA-Z0-9]/", "")
  location            = local.location
  resource_group_name = "rg-${local.vantiq_cluster_name}-${local.env_name}-aks"
  tags = {
    environment = local.env_name
    app         = local.vantiq_cluster_name
  }

  # kubernetes version
  kubernetes_version = module.constants.aks_config.kubernetes_version

  # enable private cluster
  private_cluster_enabled = module.constants.aks_config.private_cluster_enabled

  # enable container insights + loganalytics
  loganalytics_enabled = module.constants.aks_config.loganalytics_enabled

  # network profile - required. may be variable for each client
  service_cidr       = module.constants.aks_config.service_cidr
  dns_service_ip     = module.constants.aks_config.dns_service_ip
  aks_node_subnet_id = data.terraform_remote_state.network.outputs.vpc_snet_aks_node_id
  lb_subnet_id       = data.terraform_remote_state.network.outputs.vpc_snet_aks_lb_id
  #  vnet_subnet_id = data.terraform_remote_state.network.outputs.vantiq_aks_node_subnet_kubenet_id

  # network profile (optional)
  #  load_balancer_sku =  module.constants.aks_config.load_balancer_sku
  #  network_plugin =  module.constants.aks_config.network_plugin
  #  network_policy =  module.constants.aks_config.network_policy
  #  outbound_type =  module.constants.aks_config.outbound_type
  #  pod_cidr =  module.constants.aks_config.pod_cidr

  # load balancer profile (option)
  # managed_outbound_ip_count =  module.constants.aks_config.managed_outbound_ip_count
  # outbound_ip_prefix_ids =  module.constants.aks_config.outbound_ip_prefix_ids
  # outbound_ip_address_ids = module.constants.aks_config.outbound_ip_address_ids

  # linux profile
  admin_username = module.constants.aks_config.admin_username
  ssh_key        = "../${module.constants.aks_config.ssh_key}"

  # node pool
  # "Standard_F4s_v2 (4vCPU + 8GiB) - equivalent to C5.xlarge
  # "Standard_E4s_v3" (4vCPU + 32GiB) - equivalent to R5.xlarge
  # "Standard_B2S" (2vCPU + 4GiB)- equivalent to T3.medium
  # "Standard_E2_v3" (4vCPU + 32GiB) -  equivalent to M5.large
  availability_zones                                   = module.constants.aks_config.availability_zones
  vantiq_node_pool_vm_size                             = module.constants.aks_config.vantiq_node_pool_vm_size
  vantiq_node_pool_node_count                          = module.constants.aks_config.vantiq_node_pool_node_count
  vantiq_node_pool_node_ephemeral_os_disk              = module.constants.aks_config.vantiq_node_pool_node_ephemeral_os_disk
  mongodb_node_pool_vm_size                            = module.constants.aks_config.mongodb_node_pool_vm_size
  mongodb_node_pool_node_count                         = module.constants.aks_config.mongodb_node_pool_node_count
  mongodb_node_pool_node_ephemeral_os_disk             = module.constants.aks_config.mongodb_node_pool_node_ephemeral_os_disk
  userdb_node_pool_vm_size                             = module.constants.aks_config.userdb_node_pool_vm_size
  userdb_node_pool_node_count                          = module.constants.aks_config.userdb_node_pool_node_count
  userdb_node_pool_node_ephemeral_os_disk              = module.constants.aks_config.userdb_node_pool_node_ephemeral_os_disk
  grafana_node_pool_vm_size                            = module.constants.aks_config.grafana_node_pool_vm_size
  grafana_node_pool_node_count                         = module.constants.aks_config.grafana_node_pool_node_count
  grafana_node_pool_node_ephemeral_os_disk             = module.constants.aks_config.grafana_node_pool_node_ephemeral_os_disk
  keycloak_node_pool_vm_size                           = module.constants.aks_config.keycloak_node_pool_vm_size
  keycloak_node_pool_node_count                        = module.constants.aks_config.keycloak_node_pool_node_count
  keycloak_node_pool_node_ephemeral_os_disk            = module.constants.aks_config.keycloak_node_pool_node_ephemeral_os_disk
  metrics_node_pool_vm_size                            = module.constants.aks_config.metrics_node_pool_vm_size
  metrics_node_pool_node_count                         = module.constants.aks_config.metrics_node_pool_node_count
  metrics_node_pool_node_ephemeral_os_disk             = module.constants.aks_config.metrics_node_pool_node_ephemeral_os_disk
  vantiq_ai_assistant_node_pool_vm_size                = module.constants.aks_config.vantiq_ai_assistant_node_pool_vm_size
  vantiq_ai_assistant_node_pool_node_count             = module.constants.aks_config.vantiq_ai_assistant_node_pool_node_count
  vantiq_ai_assistant_node_pool_node_ephemeral_os_disk = module.constants.aks_config.vantiq_ai_assistant_node_pool_node_ephemeral_os_disk
}

###
###  storage module
###
module "storage" {
  # fixed parameter. Do not change.
  source              = "../../modules/storage"
  vantiq_cluster_name = local.vantiq_cluster_name
  location            = local.location
  tags = {
    environment = local.env_name
    app         = local.vantiq_cluster_name
  }

  resource_group_name       = "rg-${local.vantiq_cluster_name}-${local.env_name}-storage"
  storage_account_name      = replace(lower("${local.vantiq_cluster_name}${local.env_name}"), "/[^a-z0-9]/", "")
  storage_account_subnet_id = data.terraform_remote_state.network.outputs.vpc_snet_aks_node_id

  # storage account private link
  private_endpoint_vnet_ids = [data.terraform_remote_state.network.outputs.vpc_vnet_id]

  delete_after_days_since_modification_greater_than = module.constants.backup_storage_config.delete_after_days_since_modification_greater_than
}
