# network security group for aks node
resource "azurerm_network_security_group" "nsg-snet-aks-node" {
  name                = "nsg-snet-aks-node"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-vpc.name

  security_rule {
    name                       = "AllowAzureCloudInBound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureCloud"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowVnetCustomInBound"
    priority                   = 2000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = var.snet_aks_allow_inbound_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancerInBoundCustom"
    priority                   = 2010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowInterenetInBoundCustom"
    priority                   = 2020
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "DenyAllInBoundCustom"
    priority                   = 3000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAzureCloudOutBound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }

  security_rule {
    name                       = "AllowVnetCustomOutBound"
    priority                   = 2000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowInternetOutBoundCustom"
    priority                   = 2010
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = var.snet_aks_allow_outbound_port
    destination_port_ranges    = var.snet_aks_allow_outbound_ports
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  security_rule {
    name                       = "DenyAllOutBoundCustom"
    priority                   = 3000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags

}

# associate network security group to aks node
resource "azurerm_subnet_network_security_group_association" "nsg-association-snet-aks-node" {
  subnet_id                 = azurerm_subnet.snet-aks-node.id
  network_security_group_id = azurerm_network_security_group.nsg-snet-aks-node.id
}



# network security group for load balancer
resource "azurerm_network_security_group" "nsg-snet-aks-lb" {
  name                = "nsg-snet-aks-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-vpc.name

  security_rule {
    name                       = "AllowAzureCloudInBound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureCloud"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowVnetCustomInBound"
    priority                   = 2000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = var.snet_lb_allow_inbound_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancerInBoundCustom"
    priority                   = 2010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowInterenetInBoundCustom"
    priority                   = 2020
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInBoundCustom"
    priority                   = 3000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags

}

# associate network security group to load balancer
resource "azurerm_subnet_network_security_group_association" "nsg-association-aks-lb" {
  subnet_id                 = azurerm_subnet.snet-aks-lb.id
  network_security_group_id = azurerm_network_security_group.nsg-snet-aks-lb.id
}


# network security group for op node
resource "azurerm_network_security_group" "nsg-snet-op" {
  name                = "nsg-snet-op"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-vpc.name

  security_rule {
    name                       = "AllowAzureCloudInBound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureCloud"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowVnetCustomInBound"
    priority                   = 2000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.snet_op_allow_inbound_cidr
    destination_address_prefix = "*"
  }

  # effective only when public IP is enabled.
  security_rule {
    name                       = "AllowSshInBoundCustom"
    priority                   = 2020
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInBoundCustom"
    priority                   = 3000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAzureCloudOutBound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }

  security_rule {
    name                       = "AllowVnetCustomOutBound"
    priority                   = 2000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowInternetOutBoundCustom"
    priority                   = 2010
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = var.snet_op_allow_outbound_port
    destination_port_ranges    = var.snet_op_allow_outbound_ports
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  security_rule {
    name                       = "DenyAllOutBoundCustom"
    priority                   = 3000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags

}


# associate network security group to op node
resource "azurerm_subnet_network_security_group_association" "nsg-association-op" {
  subnet_id                 = azurerm_subnet.snet-op.id
  network_security_group_id = azurerm_network_security_group.nsg-snet-op.id
}
