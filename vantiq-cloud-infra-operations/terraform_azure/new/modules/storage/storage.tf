# define the resource group used
resource "azurerm_resource_group" "rg-storage" {
  name     = var.resource_group_name
  location = var.location
}

# storage account
resource "azurerm_storage_account" "vantiq" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg-storage.name
  location                 = var.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  access_tier              = "Hot"

  # security
  enable_https_traffic_only       = true
  allow_nested_items_to_be_public = false

  blob_properties {
    delete_retention_policy {
      days = 30
    }
  }

  tags = var.tags
}

# create container in storage account
resource "azurerm_storage_container" "mongodbbackup" {
  name                  = "mongodbbackup"
  storage_account_name  = azurerm_storage_account.vantiq.name
  container_access_type = "private"
}

# lifecycle management rule of storage account
resource "azurerm_storage_management_policy" "mongodbbackup" {
  storage_account_id = azurerm_storage_account.vantiq.id

  rule {
    name    = "automaticdelete"
    enabled = true
    filters {
      prefix_match = ["mongodbbackup"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = var.delete_after_days_since_modification_greater_than
      }
    }
  }
}

## private link
resource "azurerm_private_endpoint" "pe-vantiq-storage-account" {
  name                = "pe-vantiq-storage-account"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-storage.name
  subnet_id           = var.storage_account_subnet_id

  private_service_connection {
    name                           = "connection-vantiq-storage-account"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.vantiq.id
    subresource_names              = ["blob"]
  }
}


## Private DNS zone
resource "azurerm_private_dns_zone" "pdns-vantiq-storage-account" {
  ## split "xxxxxxx.blob.core.windows.net" into
  ##  "xxxxxxx" and "blob.core.windows.net" and use the second
  ## portion as DNS zone name.
  name                = format("%s.%s", "privatelink", join(".", slice(split(".", azurerm_private_endpoint.pe-vantiq-storage-account.custom_dns_configs[0].fqdn), 1, length(split(".", azurerm_private_endpoint.pe-vantiq-storage-account.custom_dns_configs[0].fqdn))))) #
  resource_group_name = azurerm_resource_group.rg-storage.name
}
# add DNS record - add to DNS zone
resource "azurerm_private_dns_a_record" "pdns-vantiq-storage-account" {
  name                = split(".", azurerm_private_endpoint.pe-vantiq-storage-account.custom_dns_configs[0].fqdn)[0]
  zone_name           = azurerm_private_dns_zone.pdns-vantiq-storage-account.name
  resource_group_name = azurerm_resource_group.rg-storage.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.pe-vantiq-storage-account.private_service_connection[0].private_ip_address]
}


# Prive DNS Zone association with VNET
resource "azurerm_private_dns_zone_virtual_network_link" "pdns-vantiq-storage-account" {
  count                 = length(var.private_endpoint_vnet_ids)
  name                  = format("pdns-vantiq-storage-account-%d", count.index)
  resource_group_name   = azurerm_resource_group.rg-storage.name
  private_dns_zone_name = azurerm_private_dns_zone.pdns-vantiq-storage-account.name
  virtual_network_id    = var.private_endpoint_vnet_ids[count.index]
}
