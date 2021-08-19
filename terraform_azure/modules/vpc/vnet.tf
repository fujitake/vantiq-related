
# define the resource group that is used throughout the cluster
resource "azurerm_resource_group" "rg-vpc" {
  name = var.resource_group_name
  location = var.location
}


# ddos protection plan is not needed when configured in closed network.
/*
resource "azurerm_network_ddos_protection_plan" "example" {
  name                = "ddospplan1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}
*/

# defaultのSGの設定は、VNET, LBからのINBOUNDが可能となっている。すなわち、Internetから直接IBCは不可。OBCは許可。
resource "azurerm_virtual_network" "vnet-vantiq" {
  name                = "vnet-vantiq"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-vpc.name
  address_space       = var.vnet_address_cidr
  dns_servers         = var.vnet_dns_servers

/*
  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.example.id
    enable = true
  }
*/
  tags = var.tags
}


/*
# private subnet for aks node (kubenet)
resource "azurerm_subnet" "snet-tf-vantiq-aks-node-kubenet" {
  name                 = "snet-${var.vantiq_cluster_name}-aks-node-kubenet"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-vantiq.name
  address_prefixes     = ["10.1.240.0/24"]
  enforce_private_link_endpoint_network_policies = true
}
*/
