output "Main_subscription_Name" {
  value = data.azurerm_subscription.current.display_name
}
output "Main_subscription_ID" {
  value = data.azurerm_subscription.current.id
}

##
## vnet
##
output "vpc_vnet_id" {
  value = module.vpc.vpc_vnet_id
}

output "vpc_vnet_address_space" {
  value = module.vpc.vpc_vnet_address_space
}

output "vpc_vnet_dns_servers" {
  value = module.vpc.vpc_vnet_dns_servers
}

##
## subnet
##
output "vpc_snet_aks_node_address_space" {
  value = module.vpc.vpc_snet_aks_node_address_space
}
output "vpc_snet_aks_node_id" {
  value = module.vpc.vpc_snet_aks_node_id
}

output "vpc_snet_op_address_space" {
  value = module.vpc.vpc_snet_op_address_space
}
output "vpc_snet_op_id" {
  value = module.vpc.vpc_snet_op_id
}

output "vpc_snet_aks_lb_address_space" {
  value = module.vpc.vpc_snet_aks_lb_address_space
}
output "vpc_snet_aks_lb_id" {
  value = module.vpc.vpc_snet_aks_lb_id
}
output "vpc_snet_aks_lb_name" {
  value = module.vpc.vpc_snet_aks_lb_name
}

/*
##
## NAT GW
##
output "vpc_pip_nat_vantiq" {
  value = module.vpc.vpc_pip_nat_vantiq
}
*/

/*
output "vantiq_svc_subnet_cidr" {
  value = module.vpc.vantiq_svc_subnet_cidr
}
*/
