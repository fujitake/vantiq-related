/*
 *  2020/9/1 update: Instead of using NAT GW, use firewall.
 *

# public IP for NAT GW
resource "azurerm_public_ip" "pip-nat-vantiq" {
  name                = "pip-nat-vantiq"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-vpc.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = var.tags
}

resource "azurerm_nat_gateway" "nat-vantiq" {
  name                    = "nat-vantiq"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-vpc.name
  sku_name                = "Standard"
#  idle_timeout_in_minutes = 10
#  zones                   = ["1"]
  tags = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "nat-pip-association-vantiq" {
  nat_gateway_id       = azurerm_nat_gateway.nat-vantiq.id
  public_ip_address_id = azurerm_public_ip.pip-nat-vantiq.id
  depends_on = []
}

resource "azurerm_subnet_nat_gateway_association" "nat-association-vantiq" {
  subnet_id      = azurerm_subnet.snet-aks-node.id
  nat_gateway_id = azurerm_nat_gateway.nat-vantiq.id
  depends_on = [azurerm_subnet_network_security_group_association.nsg-association-snet-aks-node]
}

*/
