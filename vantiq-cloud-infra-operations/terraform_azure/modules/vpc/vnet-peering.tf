#
# 2020/8/6  VNET Perring needs to be set up manually when other VNETs are available.
# if tf is to be used, then use below.
#
resource "azurerm_virtual_network_peering" "peer_vantiq_to_others" {
  count = length(var.vnet_peering_remote_vnet_ids)
  name                      = format("peer_vantiq_to_others-%d", count.index)
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.vnet-vantiq.name
  remote_virtual_network_id = var.vnet_peering_remote_vnet_ids[count.index]
}
