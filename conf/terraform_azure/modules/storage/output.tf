output "storage_fqdn" {
  value = azurerm_private_endpoint.pe-vantiq-storage-account.custom_dns_configs[0].fqdn
}

output "storage_vantiq_backup_container_name" {
  value = azurerm_storage_container.mongodbbackup.name
}

output "storage_primary_access_key" {
  value = azurerm_storage_account.vantiq.primary_access_key
}

output "storage_account_name" {
  value = azurerm_storage_account.vantiq.name
}
