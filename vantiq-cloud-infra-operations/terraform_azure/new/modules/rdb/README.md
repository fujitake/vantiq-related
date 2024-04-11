## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_postgresql_database.keycloak-db](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_database) | resource |
| [azurerm_postgresql_server.keycloak-dbserver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_server) | resource |
| [azurerm_private_dns_a_record.pdns-a-postgres](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_zone.pdns-postgres](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.pdnslk-a-postgres](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.pe-keycloak-db-server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group.rg-rdb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [random_string.postgres_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_db_server_name"></a> [db\_server\_name](#input\_db\_server\_name) | db server name. must be unique globally. alphanumeric only | `string` | `null` | no |
| <a name="input_geo_redundant_backup_enabled"></a> [geo\_redundant\_backup\_enabled](#input\_geo\_redundant\_backup\_enabled) | whether to enable geo redundant backup enabled | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Region to craete resources | `string` | `null` | no |
| <a name="input_private_endpoint_vnet_ids"></a> [private\_endpoint\_vnet\_ids](#input\_private\_endpoint\_vnet\_ids) | vnet for private DNS zone to be associated | `list(string)` | `null` | no |
| <a name="input_private_subnet_id"></a> [private\_subnet\_id](#input\_private\_subnet\_id) | subnet in which postgres server end point should be set up | `string` | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | whether to make the db server avaialble as public | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource Group to craete resources | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Region to craete resources | `map(string)` | `null` | no |
| <a name="input_vantiq_cluster_name"></a> [vantiq\_cluster\_name](#input\_vantiq\_cluster\_name) | vantiq cluster name to be used in suffix of the resource name | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_postgres_admin_password"></a> [postgres\_admin\_password](#output\_postgres\_admin\_password) | n/a |
| <a name="output_postgres_admin_user"></a> [postgres\_admin\_user](#output\_postgres\_admin\_user) | n/a |
| <a name="output_postgres_db_name"></a> [postgres\_db\_name](#output\_postgres\_db\_name) | n/a |
| <a name="output_postgres_fqdn"></a> [postgres\_fqdn](#output\_postgres\_fqdn) | n/a |
