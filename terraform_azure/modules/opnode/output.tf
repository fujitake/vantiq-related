output "opnode_IP" {
  value = azurerm_linux_virtual_machine.opnode-1.public_ip_address
}
output "opnode_FQDN" {
  value = var.public_ip_enabled ? azurerm_public_ip.pub-ip-opnode-1[0].fqdn : ""
}
output "opnode_hostname" {
  value = azurerm_linux_virtual_machine.opnode-1.computer_name
}
output "opnode_user_name" {
  value = azurerm_linux_virtual_machine.opnode-1.admin_username
}
output "opnode_ssh_key_data" {
  value = element(azurerm_linux_virtual_machine.opnode-1.admin_ssh_key[*].public_key, 0)
}
output "opnode_customdata" {
  value = azurerm_linux_virtual_machine.opnode-1.custom_data
}
