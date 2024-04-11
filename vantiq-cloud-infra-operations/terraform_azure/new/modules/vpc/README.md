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
| [azurerm_network_security_group.nsg-snet-aks-lb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.nsg-snet-aks-node](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.nsg-snet-op](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_resource_group.rg-vpc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_route.route_firewall](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route) | resource |
| [azurerm_route_table.route_table_vnet_vantiq](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_subnet.snet-aks-lb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.snet-aks-node](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.snet-op](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.nsg-association-aks-lb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.nsg-association-op](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.nsg-association-snet-aks-node](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.route_table_association_snet_aks_node](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_subnet_route_table_association.route_table_association_snet_op](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_virtual_network.vnet-vantiq](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_peering.peer_vantiq_to_others](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_firewall_ip"></a> [firewall\_ip](#input\_firewall\_ip) | IP of firewall to use. If IP is set, then the gateway is set to FW, otherwise, default Internet GW is used. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Region to craete resources | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource Group to craete resources | `string` | `null` | no |
| <a name="input_snet_aks_allow_inbound_cidr"></a> [snet\_aks\_allow\_inbound\_cidr](#input\_snet\_aks\_allow\_inbound\_cidr) | list of cidrs to allow inbound traffic from for aks node | `list(string)` | <pre>[<br>  "10.0.0.0/8"<br>]</pre> | no |
| <a name="input_snet_aks_allow_outbound_port"></a> [snet\_aks\_allow\_outbound\_port](#input\_snet\_aks\_allow\_outbound\_port) | port to allow output traffic from aks node | `string` | `null` | no |
| <a name="input_snet_aks_allow_outbound_ports"></a> [snet\_aks\_allow\_outbound\_ports](#input\_snet\_aks\_allow\_outbound\_ports) | list of ports to allow output traffic from aks node | `list(string)` | `null` | no |
| <a name="input_snet_aks_lb_address_cidr"></a> [snet\_aks\_lb\_address\_cidr](#input\_snet\_aks\_lb\_address\_cidr) | CIDR of subnet to place aks load balancer | `list(string)` | `null` | no |
| <a name="input_snet_aks_node_address_cidr"></a> [snet\_aks\_node\_address\_cidr](#input\_snet\_aks\_node\_address\_cidr) | CIDR of the private subnet | `list(string)` | `null` | no |
| <a name="input_snet_lb_allow_inbound_cidr"></a> [snet\_lb\_allow\_inbound\_cidr](#input\_snet\_lb\_allow\_inbound\_cidr) | list of cidrs to allow inbound traffic from for load balancer | `list(string)` | <pre>[<br>  "10.0.0.0/8"<br>]</pre> | no |
| <a name="input_snet_op_address_cidr"></a> [snet\_op\_address\_cidr](#input\_snet\_op\_address\_cidr) | CIDR of the op subnet | `list(string)` | `null` | no |
| <a name="input_snet_op_allow_inbound_cidr"></a> [snet\_op\_allow\_inbound\_cidr](#input\_snet\_op\_allow\_inbound\_cidr) | list of cidrs to allow inbound traffic from for op node | `list(string)` | <pre>[<br>  "10.0.0.0/8"<br>]</pre> | no |
| <a name="input_snet_op_allow_outbound_port"></a> [snet\_op\_allow\_outbound\_port](#input\_snet\_op\_allow\_outbound\_port) | port to allow output traffic from o@ | `string` | `null` | no |
| <a name="input_snet_op_allow_outbound_ports"></a> [snet\_op\_allow\_outbound\_ports](#input\_snet\_op\_allow\_outbound\_ports) | list of ports to allow output traffic from o@ | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Region to craete resources | `map(string)` | `null` | no |
| <a name="input_vantiq_cluster_name"></a> [vantiq\_cluster\_name](#input\_vantiq\_cluster\_name) | vantiq cluster name to be used in suffix of the resource name | `string` | `null` | no |
| <a name="input_vnet_address_cidr"></a> [vnet\_address\_cidr](#input\_vnet\_address\_cidr) | CIDR of the VNET | `list(string)` | <pre>[<br>  "10.0.0.0/8"<br>]</pre> | no |
| <a name="input_vnet_dns_servers"></a> [vnet\_dns\_servers](#input\_vnet\_dns\_servers) | DNS server (optional) | `list(string)` | `null` | no |
| <a name="input_vnet_peering_remote_vnet_ids"></a> [vnet\_peering\_remote\_vnet\_ids](#input\_vnet\_peering\_remote\_vnet\_ids) | list of vnet ids to link with VNET | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_snet_aks_lb_address_space"></a> [vpc\_snet\_aks\_lb\_address\_space](#output\_vpc\_snet\_aks\_lb\_address\_space) | n/a |
| <a name="output_vpc_snet_aks_lb_id"></a> [vpc\_snet\_aks\_lb\_id](#output\_vpc\_snet\_aks\_lb\_id) | n/a |
| <a name="output_vpc_snet_aks_lb_name"></a> [vpc\_snet\_aks\_lb\_name](#output\_vpc\_snet\_aks\_lb\_name) | n/a |
| <a name="output_vpc_snet_aks_node_address_space"></a> [vpc\_snet\_aks\_node\_address\_space](#output\_vpc\_snet\_aks\_node\_address\_space) | n/a |
| <a name="output_vpc_snet_aks_node_id"></a> [vpc\_snet\_aks\_node\_id](#output\_vpc\_snet\_aks\_node\_id) | n/a |
| <a name="output_vpc_snet_op_address_space"></a> [vpc\_snet\_op\_address\_space](#output\_vpc\_snet\_op\_address\_space) | n/a |
| <a name="output_vpc_snet_op_id"></a> [vpc\_snet\_op\_id](#output\_vpc\_snet\_op\_id) | n/a |
| <a name="output_vpc_vnet_address_space"></a> [vpc\_vnet\_address\_space](#output\_vpc\_vnet\_address\_space) | n/a |
| <a name="output_vpc_vnet_dns_servers"></a> [vpc\_vnet\_dns\_servers](#output\_vpc\_vnet\_dns\_servers) | n/a |
| <a name="output_vpc_vnet_id"></a> [vpc\_vnet\_id](#output\_vpc\_vnet\_id) | n/a |
