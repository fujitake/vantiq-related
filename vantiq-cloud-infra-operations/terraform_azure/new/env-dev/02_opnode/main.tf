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
###  Opnode
###
module "opnode" {
  # fixed parameter. Do not change.
  source              = "../../modules/opnode"
  vantiq_cluster_name = local.vantiq_cluster_name
  location            = local.location
  resource_group_name = "rg-${local.vantiq_cluster_name}-${local.env_name}-opnode"
  tags = {
    environment = local.env_name
    app         = local.vantiq_cluster_name
  }

  # opnode VM machine.
  opnode_host_name   = module.constants.opnode_config.opnode_host_name
  opnode_user_name   = module.constants.opnode_config.opnode_user_name
  ssh_access_enabled = module.constants.opnode_config.ssh_access_enabled
  ssh_public_key     = "../${module.constants.opnode_config.ssh_public_key}"
  #  opnode_password = module.constants.opnode_config.opnode_password    # required if ssh_access_enabled = false
  opnode_vm_size = module.constants.opnode_config.opnode_vm_size
  #  ssh_access_enabled = true
  opnode_subnet_id = data.terraform_remote_state.network.outputs.vpc_snet_op_id

  # Temporarily allow public access until expressroute is available
  public_ip_enabled = module.constants.opnode_config.public_ip_enabled
  domain_name_label = replace(lower("${local.vantiq_cluster_name}${local.env_name}"), "/[^a-z0-9]/", "")
  vm_backup_enabled = module.constants.opnode_config.vm_backup_enabled

  # used for set up opnode
  ssh_private_key_aks_node = "../${module.constants.opnode_config.ssh_private_key_aks_node}"

  bastion_kubectl_version = module.constants.common_config.opnode_kubectl_version
  bastion_jdk_version     = module.constants.common_config.opnode_jdk_version
}
