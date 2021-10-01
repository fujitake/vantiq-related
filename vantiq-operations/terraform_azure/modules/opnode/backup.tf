resource "azurerm_recovery_services_vault" "backup" {
  count = var.vm_backup_enabled ? 1 : 0
  name                = "backup-vault"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-opnode.name
  sku                 = "Standard"
  soft_delete_enabled = false
}

resource "azurerm_backup_policy_vm" "backup" {
  count = var.vm_backup_enabled ? 1 : 0
  name                = "backup-policy"
  resource_group_name = azurerm_resource_group.rg-opnode.name
  recovery_vault_name = azurerm_recovery_services_vault.backup[0].name

  backup {
    frequency = "Weekly"
    time      = "23:00"
    weekdays  = ["Sunday"]
  }

  retention_weekly {
    count    = 10
    weekdays = ["Sunday"]
  }
}

resource "azurerm_backup_protected_vm" "op-node-1" {
  count = var.vm_backup_enabled ? 1 : 0
  resource_group_name = azurerm_resource_group.rg-opnode.name
  recovery_vault_name = azurerm_recovery_services_vault.backup[0].name
  source_vm_id        = azurerm_linux_virtual_machine.opnode-1.id
  backup_policy_id    = azurerm_backup_policy_vm.backup[0].id
}
