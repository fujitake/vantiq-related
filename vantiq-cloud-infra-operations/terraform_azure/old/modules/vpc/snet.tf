# private subnet for aks node
resource "azurerm_subnet" "snet-aks-node" {
  name                 = "snet-aks-node"
  resource_group_name = azurerm_resource_group.rg-vpc.name
  virtual_network_name = azurerm_virtual_network.vnet-vantiq.name
  address_prefixes     = var.snet_aks_node_address_cidr
  enforce_private_link_endpoint_network_policies = true
}



# subnet to place opnode VM
resource "azurerm_subnet" "snet-op" {
  name                 = "snet-op"
  resource_group_name = azurerm_resource_group.rg-vpc.name
  virtual_network_name = azurerm_virtual_network.vnet-vantiq.name # 1つのVNETにまとめる
  address_prefixes     = var.snet_op_address_cidr
}


# subnet to place aks service
resource "azurerm_subnet" "snet-aks-lb" {
  name                 = "snet-lb"
  resource_group_name = azurerm_resource_group.rg-vpc.name
  virtual_network_name = azurerm_virtual_network.vnet-vantiq.name  # 1つのVNETでまとめる
  address_prefixes     = var.snet_aks_lb_address_cidr
}
