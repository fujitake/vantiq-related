provider "azurerm" {
  features {}
}

### Case by use local for terraform backend - start ###

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../01_network/terraform.tfstate"
  }
}

### Case by use local for terraform backend - end ###


### Case by use Azure Storage for terraform backend - start ###

# # store the tf-state in blob.
# # Note: variables cannot be used inside "backend" defintion

# terraform {
#     backend "azurerm" {
#       resource_group_name  = "<INPUT-YOUR-RESOURCE-GROUP>"
#       storage_account_name = "<INPUT-YOUR-STORAGE-ACCOUNT>"
#       container_name       = "<INPUT-YOUR-CONTAINER-NAME>"
#       key                  = "opnode.tfstate"
#     }
# }

# data "terraform_remote_state" "network" {
#   backend = "azurerm"
#   config = {
#       resource_group_name  = module.constants.tf_remote_backend.resource_group_name
#       storage_account_name = module.constants.tf_remote_backend.storage_account_name
#       container_name       = module.constants.tf_remote_backend.container_name
#       key                  = "network.tfstate"
#   }
# }

### Case by use S3 Bucket for terraform backend - end ###


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
}