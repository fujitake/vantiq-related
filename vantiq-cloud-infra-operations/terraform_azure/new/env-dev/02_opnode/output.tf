output "Main_subscription_Name" {
  value = data.azurerm_subscription.current.display_name
}
output "Main_subscription_ID" {
  value = data.azurerm_subscription.current.id
}
output "opnode_IP" {
  value = module.opnode.opnode_IP
}
output "opnode_FQDN" {
  value = module.opnode.opnode_FQDN
}
output "opnode_hostname" {
  value = module.opnode.opnode_hostname
}
output "opnode_user_name" {
  value = module.opnode.opnode_user_name
}
output "opnode_ssh_key_data" {
  value = module.opnode.opnode_ssh_key_data
}
output "opnode_customdata" {
  value     = module.opnode.opnode_customdata
  sensitive = true
}
