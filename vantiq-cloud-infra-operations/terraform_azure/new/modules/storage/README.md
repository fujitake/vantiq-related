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
| [azurerm_private_dns_a_record.pdns-vantiq-storage-account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_zone.pdns-vantiq-storage-account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.pdns-vantiq-storage-account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.pe-vantiq-storage-account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group.rg-storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_storage_account.vantiq](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.mongodbbackup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_management_policy.mongodbbackup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_delete_after_days_since_modification_greater_than"></a> [delete\_after\_days\_since\_modification\_greater\_than](#input\_delete\_after\_days\_since\_modification\_greater\_than) | days after which the blob should be deleted | `number` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Region to craete resources | `string` | `null` | no |
| <a name="input_private_endpoint_vnet_ids"></a> [private\_endpoint\_vnet\_ids](#input\_private\_endpoint\_vnet\_ids) | vnet for private DNS zone to be associated | `list(string)` | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource Group to craete resources | `string` | `null` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | name of storage account. must be unique in global. | `string` | `null` | no |
| <a name="input_storage_account_subnet_id"></a> [storage\_account\_subnet\_id](#input\_storage\_account\_subnet\_id) | id of the subnet to create the private endpoint | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Region to craete resources | `map(string)` | `null` | no |
| <a name="input_vantiq_cluster_name"></a> [vantiq\_cluster\_name](#input\_vantiq\_cluster\_name) | vantiq cluster name to be used in suffix of the resource name | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | n/a |
| <a name="output_storage_fqdn"></a> [storage\_fqdn](#output\_storage\_fqdn) | n/a |
| <a name="output_storage_primary_access_key"></a> [storage\_primary\_access\_key](#output\_storage\_primary\_access\_key) | n/a |
| <a name="output_storage_vantiq_backup_container_name"></a> [storage\_vantiq\_backup\_container\_name](#output\_storage\_vantiq\_backup\_container\_name) | n/a |
