
##
## vnet
##
output "vpc_vnet_id" {
  value = azurerm_virtual_network.vnet-vantiq.id
}

output "vpc_vnet_address_space" {
  value = azurerm_virtual_network.vnet-vantiq.address_space
}

output "vpc_vnet_dns_servers" {
  value = azurerm_virtual_network.vnet-vantiq.dns_servers
}

##
## subnet
##
output "vpc_snet_aks_node_address_space" {
  value = azurerm_subnet.snet-aks-node.address_prefixes
}
output "vpc_snet_aks_node_id" {
  value = azurerm_subnet.snet-aks-node.id
}

output "vpc_snet_op_address_space" {
  value = azurerm_subnet.snet-op.address_prefixes
}
output "vpc_snet_op_id" {
  value = azurerm_subnet.snet-op.id
}

output "vpc_snet_aks_lb_address_space" {
  value = azurerm_subnet.snet-aks-lb.address_prefixes
}
output "vpc_snet_aks_lb_id" {
  value = azurerm_subnet.snet-aks-lb.id
}
output "vpc_snet_aks_lb_name" {
  value = azurerm_subnet.snet-aks-lb.name
}

/*
##
## NAT GW
##
output "vpc_pip_nat_vantiq" {
  value = azurerm_public_ip.pip-nat-vantiq.ip_address
}
*/

/*
output "vantiq_svc_subnet_cidr" {
#  value = azurerm_subnet.snet-tf-aks-svc-cidr.address_prefixes
  value = var.svc_subnet_aks_svc_cidr

  # explicitly depends on completion of vnet peering
#  depends_on = [azurerm_virtual_network_peering.peer_vantiq_to_svc, azurerm_virtual_network_peering.peer_svc_to_vantiq]
}
*/
