
output "postgres_fqdn" {
  value = azurerm_postgresql_server.keycloak-dbserver.fqdn
}
output "postgres_admin_user" {
  value = format("%s@%s", azurerm_postgresql_server.keycloak-dbserver.administrator_login, element(split(".", azurerm_postgresql_server.keycloak-dbserver.fqdn), 0))
}
output "postgres_admin_password" {
  value = azurerm_postgresql_server.keycloak-dbserver.administrator_login_password
}
output "postgres_db_name" {
  value = azurerm_postgresql_database.keycloak-db.name
}
