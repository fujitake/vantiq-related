##
## Main
###
output "Main_subscription_Name" {
  value = data.azurerm_subscription.current.display_name
}
output "Main_subscription_ID" {
  value = data.azurerm_subscription.current.id
}

##
## VPC
##
output "vpc_vnet_id" {
  value = data.terraform_remote_state.network.outputs.vpc_vnet_id
}

output "vpc_vnet_address_space" {
  value = data.terraform_remote_state.network.outputs.vpc_vnet_address_space
}

output "vpc_vnet_dns_servers" {
  value = data.terraform_remote_state.network.outputs.vpc_vnet_dns_servers
}

output "vpc_snet_aks_node_address_space" {
  value = data.terraform_remote_state.network.outputs.vpc_snet_aks_node_address_space
}

output "vpc_snet_op_address_space" {
  value = data.terraform_remote_state.network.outputs.vpc_snet_op_address_space
}

output "vpc_snet_aks_lb_address_space" {
  value = data.terraform_remote_state.network.outputs.vpc_snet_aks_lb_address_space
}
output "vpc_snet_aks_lb_name" {
  value = data.terraform_remote_state.network.outputs.vpc_snet_aks_lb_name
}

##
## storage
##
output "storage_fqdn" {
  value = module.storage.storage_fqdn
}

output "storage_vantiq_backup_container_name" {
  value = module.storage.storage_vantiq_backup_container_name
}

output "storage_primary_access_key" {
  value     = module.storage.storage_primary_access_key
  sensitive = true
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

##
## RDB
##
output "rdb_postgres_fqdn" {
  value = module.rdb.postgres_fqdn
}
output "rdb_postgres_admin_user" {
  value = module.rdb.postgres_admin_user
}
output "rdb_postgres_admin_password" {
  value     = module.rdb.postgres_admin_password
  sensitive = true
}
output "rdb_postgres_db_name" {
  value = module.rdb.postgres_db_name
}

##
## opnode
##
output "opnode_IP" {
  value = data.terraform_remote_state.opnode.outputs.opnode_IP
}
output "opnode_hostname" {
  value = data.terraform_remote_state.opnode.outputs.opnode_hostname
}
output "opnode_user_name" {
  value = data.terraform_remote_state.opnode.outputs.opnode_user_name
}
output "opnode_ssh_key_data" {
  value = data.terraform_remote_state.opnode.outputs.opnode_ssh_key_data
}
output "opnode_FQDN" {
  value = data.terraform_remote_state.opnode.outputs.opnode_FQDN
}
output "opnode_customdata" {
  value     = data.terraform_remote_state.opnode.outputs.opnode_customdata
  sensitive = true
}

##
## AKS
##

output "aks_kube_config" {
  value     = module.aks.aks_private_cluster_enabled ? "N/A" : module.aks.aks_kube_config
  sensitive = true
}

output "aks_kubernetes_cluster_name" {
  value = module.aks.aks_kubernetes_cluster_name
}

output "aks_kube_config_update_command" {
  value = module.aks.aks_kube_config_update_command
}

output "aks_service_principal_id" {
  value = module.aks.aks_service_principal_id
}

output "aks_service_principal_password" {
  value     = module.aks.aks_service_principal_password
  sensitive = true
}

output "aks_api_endpoint_private_fqdn" {
  value = module.aks.aks_api_endpoint_private_fqdn
}

output "aks_network_dns" {
  value = module.aks.aks_network_dns
}

output "aks_network_plugin" {
  value = module.aks.aks_network_plugin
}

output "aks_network_policy" {
  value = module.aks.aks_network_policy
}

output "aks_network_service_cidr" {
  value = module.aks.aks_network_service_cidr
}

output "aks_linux_admin_user_name" {
  value = module.aks.aks_linux_admin_user_name
}

output "aks_linux_ssh_key" {
  value = module.aks.aks_linux_ssh_key
}

output "aks_nodegroup_vantiq_vm_size" {
  value = module.aks.aks_nodegroup_vantiq_vm_size
}

output "aks_nodegroup_vantiq_node_count" {
  value = module.aks.aks_nodegroup_vantiq_node_count
}

output "aks_nodegroup_mongodb_vm_size" {
  value = module.aks.aks_nodegroup_mongodb_vm_size
}

output "aks_nodegroup_mongodb_node_count" {
  value = module.aks.aks_nodegroup_mongodb_node_count
}

output "aks_nodegroup_keycloak_vm_size" {
  value = module.aks.aks_nodegroup_keycloak_vm_size
}

output "aks_nodegroup_keycloak_node_count" {
  value = module.aks.aks_nodegroup_keycloak_node_count
}

output "aks_nodegroup_grafana_vm_size" {
  value = module.aks.aks_nodegroup_grafana_vm_size
}

output "aks_nodegroup_grafana_node_count" {
  value = module.aks.aks_nodegroup_grafana_node_count
}

output "aks_nodegroup_metric_vm_size" {
  value = module.aks.aks_nodegroup_metric_vm_size
}

output "aks_nodegroup_metric_node_count" {
  value = module.aks.aks_nodegroup_metric_node_count
}

output "aks_nodegroup_vantiq_ai_assistant_vm_size" {
  value = module.aks.aks_nodegroup_vantiq_ai_assistant_vm_size
}

output "aks_nodegroup_vantiq_ai_assistant_node_count" {
  value = module.aks.aks_nodegroup_vantiq_ai_assistant_node_count
}
