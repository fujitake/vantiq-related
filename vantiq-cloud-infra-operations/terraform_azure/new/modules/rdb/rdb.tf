
# generate password string to be used in DB.
resource "random_string" "postgres_password" {
  length           = 8
  special          = true
  override_special = "@$!"
  min_special      = 1
}

# define the resource group that is used throughout the cluster
resource "azurerm_resource_group" "rg-rdb" {
  name     = var.resource_group_name
  location = var.location
}


resource "azurerm_postgresql_server" "keycloak-dbserver" {
  name                = var.db_server_name # change name
  resource_group_name = azurerm_resource_group.rg-rdb.name
  location            = var.location

  sku_name = "GP_Gen5_2"

  storage_mb                   = 102400
  backup_retention_days        = 7
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled
  auto_grow_enabled            = false

  administrator_login           = "keycloak"
  administrator_login_password  = random_string.postgres_password.result
  version                       = "11"
  ssl_enforcement_enabled       = false
  public_network_access_enabled = var.public_network_access_enabled

  tags = var.tags
}


# This is for debug. Not required when private endpoint is configured.
#resource "azurerm_postgresql_firewall_rule" "pub" {
#  name                = "pub"
#  resource_group_name = azurerm_resource_group.rg-tf-main.name
#  server_name         = azurerm_postgresql_server.keycloak-dbserver.name
#  start_ip_address    = "0.0.0.0"
#  end_ip_address      = "255.255.255.255"
#}


resource "azurerm_postgresql_database" "keycloak-db" {
  name                = "keycloak"
  resource_group_name = azurerm_resource_group.rg-rdb.name
  server_name         = azurerm_postgresql_server.keycloak-dbserver.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}


## private link
resource "azurerm_private_endpoint" "pe-keycloak-db-server" {
  name                = "pe-keycloak-db-server"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-rdb.name
  subnet_id           = var.private_subnet_id

  private_service_connection {
    name                           = "tfex-postgresql-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_postgresql_server.keycloak-dbserver.id
    subresource_names              = ["postgresqlServer"]
  }
}

## Private DNS zone
resource "azurerm_private_dns_zone" "pdns-postgres" {
  ## split "keycloakdbserver.privatelink.postgres.database.azure.com" into
  ##  "keycloakdbserver" and "privatelink.postgres.database.azure.com" and use the second
  ## portion as DNS zone name.
  name                = format("%s.%s", "privatelink", join(".", slice(split(".", azurerm_postgresql_server.keycloak-dbserver.fqdn), 1, length(split(".", azurerm_postgresql_server.keycloak-dbserver.fqdn))))) #
  resource_group_name = var.resource_group_name
}
# add DNS record - add to DNS zone
resource "azurerm_private_dns_a_record" "pdns-a-postgres" {
  name                = split(".", azurerm_postgresql_server.keycloak-dbserver.fqdn)[0] # keycloakdbserver
  zone_name           = azurerm_private_dns_zone.pdns-postgres.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.pe-keycloak-db-server.private_service_connection[0].private_ip_address]
}

# Prive DNS Zone association with VNET
resource "azurerm_private_dns_zone_virtual_network_link" "pdnslk-a-postgres" {
  count                 = length(var.private_endpoint_vnet_ids)
  name                  = format("pdnslk-a-postgres-%d", count.index)
  resource_group_name   = azurerm_resource_group.rg-rdb.name
  private_dns_zone_name = azurerm_private_dns_zone.pdns-postgres.name
  virtual_network_id    = var.private_endpoint_vnet_ids[count.index]
}
