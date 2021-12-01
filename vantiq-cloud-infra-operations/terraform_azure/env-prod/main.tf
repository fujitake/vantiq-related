###
###  Terraform configuration
###
/*
provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x.
    # If you are using version 1.x, the "features" block is not allowed.
    version = "~>2.52.0"
    features {}
}

provider "azuread" {
  version = "=1.0.0"
}

provider "random" {

    version = "~>2.3.0"
}
*/
terraform {
  required_providers {
    azurerm = {
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
provider "azurerm" {
    features {}
}


# store the tf-state in blob.
# Note: variables cannot be used inside "backend" defintion
/*
terraform {

    backend "azurerm" {
      resource_group_name  = "rg-vantiq-tf"
      storage_account_name = "vantiqtfkono"
      container_name       = "tfstate"

      key                  = "prod.terraform.tfstate"
#      key                  = "dev.terraform.tfstate"
    }
}
*/

# store the tf-state in local directory
terraform {
    backend "local" {
      path = "terraform.tfstate"  # change the path to unique name
    }
}


###
###  Subscription, Resource Group
###

# obtain current active subscription
data "azurerm_subscription" "current" {
}

# define the resource group that is used throughout the cluster
resource "azurerm_resource_group" "rg-tf-main" {
  name = "rg-${var.vantiq_cluster_name}-${var.env_name}"
  location = var.location
}


###
###  VPC module
###
module "vpc" {
  # fixed parameter. Do not change.
  source = "../modules/vpc"
  vantiq_cluster_name = var.vantiq_cluster_name
  location = var.location
  resource_group_name = "rg-${var.vantiq_cluster_name}-${var.env_name}-vpc"
  tags = {
     environment = var.env_name
     app = var.vantiq_cluster_name
  }

  # vnet
  vnet_address_cidr = ["10.1.0.0/16"]
  vnet_dns_servers = null  # default
#  vnet_dns_servers =  ["XX.X.X.3", "XX.X.X.4"]

  # subnets
  snet_aks_node_address_cidr = ["10.1.48.0/20"]
  snet_aks_lb_address_cidr = ["10.1.1.128/25"]
  snet_op_address_cidr = ["10.1.2.0/27"]

  # network security groups
  # amqps : TCP 5671
  # mqtt : 1883, 8883, 12470 (ws), 12473 (wss)
  # git : TCP 9418
  # https: TCP 443
  # kafka : TCP 9092, 8083
  # dns : TCP 53
  # smtp: 25, 587

  snet_aks_allow_inbound_cidr = ["10.0.0.0/8"]  # replace with more stricted cidr
  snet_aks_allow_outbound_port = "*"
#  snet_aks_allow_outbound_ports = ["25", "443", "587", "9418", "1883", "8883", "12470", "12473", "9092", "8083"] # smtp, https, smtps, git, mqtts, amqps,kafka

  snet_op_allow_inbound_cidr = ["10.0.0.0/8"]  # replace with more stricted cidr
  snet_op_allow_outbound_port = "*"
#  snet_op_allow_outbound_ports = ["25", "443", "587", "9418", "80"]   # smtp, https, smtps, git, http

  snet_lb_allow_inbound_cidr = ["10.0.0.0/8"]  # replace with more stricted cidr

  # vnet-peering. use if vnet ids are already known
  vnet_peering_remote_vnet_ids = []

    # firewall IP. if not used, it will use default internet gateway.
  #  firewall_ip = "10.20.1.4"
}

###
###  storage module
###
module "storage" {
  # fixed parameter. Do not change.
  source = "../modules/storage"
  vantiq_cluster_name = var.vantiq_cluster_name
  location = var.location
  tags = {
     environment = var.env_name
     app = var.vantiq_cluster_name
  }
  depends_on = [module.vpc]

  resource_group_name = "rg-${var.vantiq_cluster_name}-${var.env_name}-storage"
  storage_account_name = "${var.vantiq_cluster_name}${var.env_name}"
  storage_account_subnet_id = module.vpc.vpc_snet_aks_node_id

  # storage account private link
  private_endpoint_vnet_ids = [module.vpc.vpc_vnet_id]

  delete_after_days_since_modification_greater_than = 3

}


###
###  RDB
###
module "rdb" {
  # fixed parameter. Do not change.
  source = "../modules/rdb"
  vantiq_cluster_name = var.vantiq_cluster_name
  location = var.location
  resource_group_name = "rg-${var.vantiq_cluster_name}-${var.env_name}-rdb"
  depends_on = [module.vpc]

  db_server_name = "keycloak${var.vantiq_cluster_name}${var.env_name}"
  public_network_access_enabled = false
  tags = {
     environment = var.env_name
     app = var.vantiq_cluster_name
  }

#  private_endpoint_vnet_ids = [module.vpc.vnet_id, module.vpc.vnet_svc_id]
  private_endpoint_vnet_ids = [module.vpc.vpc_vnet_id]
  private_subnet_id = module.vpc.vpc_snet_aks_node_id
}


###
###  Opnode
###
module "opnode" {
  # fixed parameter. Do not change.
  source = "../modules/opnode"
  vantiq_cluster_name = var.vantiq_cluster_name
  location = var.location
  resource_group_name = "rg-${var.vantiq_cluster_name}-${var.env_name}-opnode"
  tags = {
     environment = var.env_name
     app = var.vantiq_cluster_name
  }
  depends_on = [module.vpc]

  # opnode VM machine.
  opnode_host_name = "opnode-1"
  opnode_user_name = "system"
  ssh_access_enabled = true
  ssh_public_key = "./opnode_id_rsa.pub"   # required if ssh_access_enabled = true
#  opnode_password = "EventDriven6"      # required if ssh_access_enabled = false
  opnode_vm_size = "Standard_B1ms"
#  ssh_access_enabled = true
  opnode_subnet_id = module.vpc.vpc_snet_op_id

  # Temporarily allow public access until expressroute is available
  public_ip_enabled = true
  domain_name_label = "${var.vantiq_cluster_name}-${var.env_name}"
  vm_backup_enabled = true

  # used for set up opnode
  ssh_private_key_aks_node = "./aks_node_id_rsa"
}


###
###  AKS
###
module "aks" {
  # fixed parameter. Do not change.
  source = "../modules/aks"
  aks_cluster_name = "aks-${var.vantiq_cluster_name}-${var.env_name}"
  location = var.location
  resource_group_name = "rg-${var.vantiq_cluster_name}-${var.env_name}-aks"
  tags = {
     environment = var.env_name
     app = var.vantiq_cluster_name
  }
  depends_on = [module.vpc]

  # kubernetes version
  kubernetes_version = "1.19.11"

  # enable private cluster
  private_cluster_enabled = false

  # enable container insights + loganalytics
  loganalytics_enabled = false

  # netowrk profile - required. may be variable for each client
  service_cidr = "10.1.1.0/25"
  dns_service_ip = "10.1.1.10"
  aks_node_subnet_id = module.vpc.vpc_snet_aks_node_id
  lb_subnet_id = module.vpc.vpc_snet_aks_lb_id
  #  vnet_subnet_id = module.vpc.vantiq_aks_node_subnet_kubenet_id

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
  ssh_key = "./aks_node_id_rsa.pub"

  # node pool
  # "Standard_F4s_v2 (4vCPU + 8GiB) - equivalent to C5.xlarge
  # "Standard_E4s_v3" (4vCPU + 32GiB) - equivalent to R5.xlarge
  # "Standard_B2S" (2vCPU + 4GiB)- equivalent to T3.medium
  # "Standard_E2_v3" (4vCPU + 32GiB) -  equivalent to M5.large
  availability_zones = [1, 2, 3]
  vantiq_node_pool_vm_size = "Standard_F4s_v2"
  vantiq_node_pool_node_count = 3
  vantiq_node_pool_node_ephemeral_os_disk = true
  mongodb_node_pool_vm_size = "Standard_E4s_v3"
  mongodb_node_pool_node_count = 3
  mongodb_node_pool_node_ephemeral_os_disk = true
  userdb_node_pool_vm_size = "Standard_E4s_v3"
  userdb_node_pool_node_count = 0
  userdb_node_pool_node_ephemeral_os_disk = true
  grafana_node_pool_vm_size = "Standard_E4s_v3"
  grafana_node_pool_node_count = 1
  grafana_node_pool_node_ephemeral_os_disk = true
  keycloak_node_pool_vm_size = "Standard_B2S"
  keycloak_node_pool_node_count = 3
  keycloak_node_pool_node_ephemeral_os_disk = false
  metrics_node_pool_vm_size = "Standard_F4s_v2"
  metrics_node_pool_node_count = 1
  metrics_node_pool_node_ephemeral_os_disk = true
}
