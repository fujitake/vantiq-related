## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_backup_policy_vm.backup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_policy_vm) | resource |
| [azurerm_backup_protected_vm.op-node-1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_vm) | resource |
| [azurerm_linux_virtual_machine.opnode-1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.nic-opnode-1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_public_ip.pub-ip-opnode-1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_recovery_services_vault.backup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault) | resource |
| [azurerm_resource_group.rg-opnode](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_jdk_version"></a> [bastion\_jdk\_version](#input\_bastion\_jdk\_version) | install jdk version | `string` | `"11"` | no |
| <a name="input_bastion_kubectl_version"></a> [bastion\_kubectl\_version](#input\_bastion\_kubectl\_version) | install kubectl version | `string` | `"$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"` | no |
| <a name="input_domain_name_label"></a> [domain\_name\_label](#input\_domain\_name\_label) | domain label for public IP | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Region to craete resources | `string` | `null` | no |
| <a name="input_opnode_host_name"></a> [opnode\_host\_name](#input\_opnode\_host\_name) | Hostname of the VM | `string` | `null` | no |
| <a name="input_opnode_password"></a> [opnode\_password](#input\_opnode\_password) | password for opnode VM | `string` | `null` | no |
| <a name="input_opnode_subnet_id"></a> [opnode\_subnet\_id](#input\_opnode\_subnet\_id) | subnet for opnode. either public subnet, or gateway subnet should be specified | `string` | `null` | no |
| <a name="input_opnode_user_name"></a> [opnode\_user\_name](#input\_opnode\_user\_name) | Login user name for opnode VM | `string` | `null` | no |
| <a name="input_opnode_vm_size"></a> [opnode\_vm\_size](#input\_opnode\_vm\_size) | spec of opnode VM | `string` | `"Standard_B2s"` | no |
| <a name="input_public_ip_enabled"></a> [public\_ip\_enabled](#input\_public\_ip\_enabled) | whether to temporarily allow access via public IP | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource Group to craete resources | `string` | `null` | no |
| <a name="input_ssh_access_enabled"></a> [ssh\_access\_enabled](#input\_ssh\_access\_enabled) | whether ssh access is required. true: ssh, false: password | `bool` | `true` | no |
| <a name="input_ssh_private_key_aks_node"></a> [ssh\_private\_key\_aks\_node](#input\_ssh\_private\_key\_aks\_node) | public key to use to connect to aks node | `string` | `null` | no |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | public key for ssh login | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Region to craete resources | `map(string)` | `null` | no |
| <a name="input_vantiq_cluster_name"></a> [vantiq\_cluster\_name](#input\_vantiq\_cluster\_name) | vantiq cluster name to be used in suffix of the resource name | `string` | `null` | no |
| <a name="input_vm_backup_enabled"></a> [vm\_backup\_enabled](#input\_vm\_backup\_enabled) | enable weekly backup of opnode | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_opnode_FQDN"></a> [opnode\_FQDN](#output\_opnode\_FQDN) | n/a |
| <a name="output_opnode_IP"></a> [opnode\_IP](#output\_opnode\_IP) | n/a |
| <a name="output_opnode_customdata"></a> [opnode\_customdata](#output\_opnode\_customdata) | n/a |
| <a name="output_opnode_hostname"></a> [opnode\_hostname](#output\_opnode\_hostname) | n/a |
| <a name="output_opnode_ssh_key_data"></a> [opnode\_ssh\_key\_data](#output\_opnode\_ssh\_key\_data) | n/a |
| <a name="output_opnode_user_name"></a> [opnode\_user\_name](#output\_opnode\_user\_name) | n/a |
