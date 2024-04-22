module "constants" {
  source = "../"
}

data "azurerm_subscription" "current" {}

locals {
  vantiq_cluster_name = module.constants.common_config.vantiq_cluster_name
  env_name            = module.constants.common_config.env_name
  location            = module.constants.common_config.location
}

# define the resource group that is used throughout the cluster
resource "azurerm_resource_group" "rg-tf-main" {
  name     = "rg-${local.vantiq_cluster_name}-${local.env_name}"
  location = local.location
}

##
###  VPC module
###
module "vpc" {
  # fixed parameter. Do not change.
  source              = "../../modules/vpc"
  vantiq_cluster_name = module.constants.common_config.vantiq_cluster_name
  location            = local.location
  resource_group_name = "rg-${local.vantiq_cluster_name}-${local.env_name}-vpc"
  tags = {
    environment = local.env_name
    app         = local.vantiq_cluster_name
  }

  # vnet
  vnet_address_cidr = module.constants.network_config.vnet_address_cidr
  vnet_dns_servers  = module.constants.network_config.vnet_dns_servers

  # subnets
  snet_aks_node_address_cidr = module.constants.network_config.snet_aks_node_address_cidr
  snet_aks_lb_address_cidr   = module.constants.network_config.snet_aks_lb_address_cidr
  snet_op_address_cidr       = module.constants.network_config.snet_op_address_cidr

  # network security groups
  # amqps : TCP 5671
  # mqtt : 1883, 8883, 12470 (ws), 12473 (wss)
  # git : TCP 9418
  # https: TCP 443
  # kafka : TCP 9092, 8083
  # dns : TCP 53
  # smtp: 25, 587

  snet_aks_allow_inbound_cidr  = module.constants.network_config.snet_aks_allow_inbound_cidr
  snet_aks_allow_outbound_port = module.constants.network_config.snet_aks_allow_outbound_port

  snet_op_allow_inbound_cidr  = module.constants.network_config.snet_op_allow_inbound_cidr
  snet_op_allow_outbound_port = module.constants.network_config.snet_op_allow_outbound_port

  snet_lb_allow_inbound_cidr = module.constants.network_config.snet_lb_allow_inbound_cidr

  vnet_peering_remote_vnet_ids = module.constants.network_config.vnet_peering_remote_vnet_ids

  # firewall IP. if not used, it will use default internet gateway.
  #  firewall_ip = "10.20.1.4"
}
