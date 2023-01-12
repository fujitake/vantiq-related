
resource "azurerm_route_table" "route_table_vnet_vantiq" {
  name                = "route_table_vnet_vantiq"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-vpc.name
}

# if firewall_ip is set, then set the route to firewall to override the default, otherwise let it be default
resource "azurerm_route" "route_firewall" {
  count = var.firewall_ip != null ? 1 : 0
  name                = "route_firewall"
  resource_group_name = azurerm_resource_group.rg-vpc.name
  route_table_name    = azurerm_route_table.route_table_vnet_vantiq.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_ip
}

# associate route table and anet-aksnode
resource "azurerm_subnet_route_table_association" "route_table_association_snet_aks_node" {
  subnet_id      = azurerm_subnet.snet-aks-node.id
  route_table_id = azurerm_route_table.route_table_vnet_vantiq.id
}

# associate route table and snet-op
resource "azurerm_subnet_route_table_association" "route_table_association_snet_op" {
  subnet_id      = azurerm_subnet.snet-op.id
  route_table_id = azurerm_route_table.route_table_vnet_vantiq.id
}
