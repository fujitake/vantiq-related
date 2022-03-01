# define the resource group that is used throughout the cluster
resource "azurerm_resource_group" "rg-opnode" {
  name = var.resource_group_name
  location = var.location
}

# opnode server for k8s operation
resource "azurerm_public_ip" "pub-ip-opnode-1" {
    count = var.public_ip_enabled ? 1 : 0  # conditionally create public IP
    name                         = "pub-ip-opnode-1"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rg-opnode.name
    allocation_method            = "Static"
    sku                          = "Standard"
    domain_name_label            = var.domain_name_label
    tags = var.tags
}

resource "azurerm_network_interface" "nic-opnode-1" {
  name                = "nic-opnode-1"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.rg-opnode.name

  ip_configuration {
    name                          = "opnode-1-ip-configuration"
    subnet_id                     = var.opnode_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_enabled ? azurerm_public_ip.pub-ip-opnode-1[0].id : null  # conditionally allocate public IP

  }
}

resource "azurerm_linux_virtual_machine" "opnode-1" {
    name                  = "opnode-1"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg-opnode.name
    size                  = var.opnode_vm_size
    network_interface_ids = [azurerm_network_interface.nic-opnode-1.id]


    os_disk {
        name              = "myOsDisk-opnode"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = var.opnode_host_name
    disable_password_authentication = var.ssh_access_enabled

    admin_username = var.opnode_user_name

    # either admin_password OR admin_ssh_key is required
    admin_password = var.ssh_access_enabled ? null : var.opnode_password

    dynamic "admin_ssh_key" {
      for_each = var.ssh_access_enabled ? tolist(["1"]) : []
      content {
        username = var.opnode_user_name
        public_key = file(var.ssh_public_key)
      }
    }

    custom_data = base64encode(templatefile("${path.module}/init-script.sh", {
        user_name = var.opnode_user_name
        ssh_key = file(var.ssh_private_key_aks_node)

      }))

    tags = var.tags
}
