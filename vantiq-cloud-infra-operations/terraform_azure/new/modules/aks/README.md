## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_application.aks](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_service_principal.aks](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal_password.aks](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal_password) | resource |
| [azurerm_kubernetes_cluster.aks-vantiq](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.grafananp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_kubernetes_cluster_node_pool.metricsnp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_kubernetes_cluster_node_pool.mongodbnp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_kubernetes_cluster_node_pool.userdbnp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_kubernetes_cluster_node_pool.vantiqaiasnp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_kubernetes_cluster_node_pool.vantiqnp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_log_analytics_solution.k8s](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_solution) | resource |
| [azurerm_log_analytics_workspace.k8s](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.rg-aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.aks_lb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_node_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_string.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | The Network Range used by the Kubernetes service. | `string` | `null` | no |
| <a name="input_aks_cluster_name"></a> [aks\_cluster\_name](#input\_aks\_cluster\_name) | vantiq cluster name to be used in suffix of the resource name | `string` | `null` | no |
| <a name="input_aks_node_subnet_id"></a> [aks\_node\_subnet\_id](#input\_aks\_node\_subnet\_id) | subnet in which node group should be set up | `string` | `null` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | availability zones for aks control plane and node pool | `list(number)` | <pre>[<br>  1,<br>  2,<br>  3<br>]</pre> | no |
| <a name="input_create_service_principal"></a> [create\_service\_principal](#input\_create\_service\_principal) | subnet id to place the loadbalancer | `bool` | `false` | no |
| <a name="input_dns_service_ip"></a> [dns\_service\_ip](#input\_dns\_service\_ip) | DNS service IP for cluster. This IP must be within the range of Service CIDR | `string` | `null` | no |
| <a name="input_grafana_node_pool_node_count"></a> [grafana\_node\_pool\_node\_count](#input\_grafana\_node\_pool\_node\_count) | VM count for grafana node pool | `number` | `1` | no |
| <a name="input_grafana_node_pool_node_ephemeral_os_disk"></a> [grafana\_node\_pool\_node\_ephemeral\_os\_disk](#input\_grafana\_node\_pool\_node\_ephemeral\_os\_disk) | Use of Ephemeral OS Disk for grafana node pool | `bool` | `true` | no |
| <a name="input_grafana_node_pool_vm_size"></a> [grafana\_node\_pool\_vm\_size](#input\_grafana\_node\_pool\_vm\_size) | VM size for grafana node pool | `string` | `null` | no |
| <a name="input_keycloak_node_pool_node_count"></a> [keycloak\_node\_pool\_node\_count](#input\_keycloak\_node\_pool\_node\_count) | VM count for keycloak node pool | `number` | `1` | no |
| <a name="input_keycloak_node_pool_node_ephemeral_os_disk"></a> [keycloak\_node\_pool\_node\_ephemeral\_os\_disk](#input\_keycloak\_node\_pool\_node\_ephemeral\_os\_disk) | Use of Ephemeral OS Disk for keycloak node pool | `bool` | `true` | no |
| <a name="input_keycloak_node_pool_vm_size"></a> [keycloak\_node\_pool\_vm\_size](#input\_keycloak\_node\_pool\_vm\_size) | VM size for keycloak node pool | `string` | `null` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | kubernetes version | `string` | `null` | no |
| <a name="input_lb_subnet_id"></a> [lb\_subnet\_id](#input\_lb\_subnet\_id) | subnet id to place the loadbalancer | `string` | `null` | no |
| <a name="input_load_balancer_sku"></a> [load\_balancer\_sku](#input\_load\_balancer\_sku) | load balacer sku. must be standard or higher | `string` | `"standard"` | no |
| <a name="input_location"></a> [location](#input\_location) | Region to craete resources | `string` | `null` | no |
| <a name="input_log_analytics_workspace_sku"></a> [log\_analytics\_workspace\_sku](#input\_log\_analytics\_workspace\_sku) | sku for log\_analytics\_workspace\_sku | `string` | `"standard"` | no |
| <a name="input_loganalytics_enabled"></a> [loganalytics\_enabled](#input\_loganalytics\_enabled) | whether log analytics should be enabled | `bool` | `false` | no |
| <a name="input_managed_outbound_ip_count"></a> [managed\_outbound\_ip\_count](#input\_managed\_outbound\_ip\_count) | Count of desired managed outbound IPs for the cluster load balancer. Must be in the range of [1, 100]. | `number` | `null` | no |
| <a name="input_metrics_node_pool_node_count"></a> [metrics\_node\_pool\_node\_count](#input\_metrics\_node\_pool\_node\_count) | VM count for metrics node pool | `number` | `1` | no |
| <a name="input_metrics_node_pool_node_ephemeral_os_disk"></a> [metrics\_node\_pool\_node\_ephemeral\_os\_disk](#input\_metrics\_node\_pool\_node\_ephemeral\_os\_disk) | Use of Ephemeral OS Disk for metrics node pool | `bool` | `true` | no |
| <a name="input_metrics_node_pool_vm_size"></a> [metrics\_node\_pool\_vm\_size](#input\_metrics\_node\_pool\_vm\_size) | VM size for metrics node pool | `string` | `null` | no |
| <a name="input_mongodb_node_pool_node_count"></a> [mongodb\_node\_pool\_node\_count](#input\_mongodb\_node\_pool\_node\_count) | VM count for monbodb node pool | `number` | `1` | no |
| <a name="input_mongodb_node_pool_node_ephemeral_os_disk"></a> [mongodb\_node\_pool\_node\_ephemeral\_os\_disk](#input\_mongodb\_node\_pool\_node\_ephemeral\_os\_disk) | Use of Ephemeral OS Disk for mongodb node pool | `bool` | `true` | no |
| <a name="input_mongodb_node_pool_vm_size"></a> [mongodb\_node\_pool\_vm\_size](#input\_mongodb\_node\_pool\_vm\_size) | VM size for monbodb node pool | `string` | `null` | no |
| <a name="input_network_plugin"></a> [network\_plugin](#input\_network\_plugin) | network plugin. azure or kubenet | `string` | `"azure"` | no |
| <a name="input_network_policy"></a> [network\_policy](#input\_network\_policy) | network policy. calico or azure | `string` | `"azure"` | no |
| <a name="input_outbound_ip_address_ids"></a> [outbound\_ip\_address\_ids](#input\_outbound\_ip\_address\_ids) | The ID of the Public IP Addresses which should be used for outbound communication for the cluster load balancer. | `list(string)` | `null` | no |
| <a name="input_outbound_ip_prefix_ids"></a> [outbound\_ip\_prefix\_ids](#input\_outbound\_ip\_prefix\_ids) | The ID of the outbound Public IP Address Prefixes which should be used for the cluster load balancer. | `list(string)` | `null` | no |
| <a name="input_outbound_type"></a> [outbound\_type](#input\_outbound\_type) | outbound type of routing method. loadBalancer or userDefinedRouting | `string` | `"loadBalancer"` | no |
| <a name="input_pod_cidr"></a> [pod\_cidr](#input\_pod\_cidr) | The CIDR to use for pod IP addresses. This field can only be set when network\_plugin is set to kubenet. | `string` | `null` | no |
| <a name="input_private_cluster_enabled"></a> [private\_cluster\_enabled](#input\_private\_cluster\_enabled) | Whether API endpoit should be private. True = private only, false = public only | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource Group to craete resources | `string` | `null` | no |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | The Network Range used by the Kubernetes service. | `string` | `null` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | public key for ssh login | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Region to craete resources | `map(string)` | `null` | no |
| <a name="input_userdb_node_pool_node_count"></a> [userdb\_node\_pool\_node\_count](#input\_userdb\_node\_pool\_node\_count) | VM count for monbodb node pool | `number` | `0` | no |
| <a name="input_userdb_node_pool_node_ephemeral_os_disk"></a> [userdb\_node\_pool\_node\_ephemeral\_os\_disk](#input\_userdb\_node\_pool\_node\_ephemeral\_os\_disk) | Use of Ephemeral OS Disk for userdb node pool | `bool` | `true` | no |
| <a name="input_userdb_node_pool_vm_size"></a> [userdb\_node\_pool\_vm\_size](#input\_userdb\_node\_pool\_vm\_size) | VM size for monbodb node pool | `string` | `null` | no |
| <a name="input_ai_assistant_node_pool_node_count"></a> [vantiq\_ai\_assistant\_node\_pool\_node\_count](#input\_vantiq\_ai\_assistant\_node\_pool\_node\_count) | VM count for Vantiq ai assistant node pool | `number` | `1` | no |
| <a name="input_ai_assistant_node_pool_node_ephemeral_os_disk"></a> [vantiq\_ai\_assistant\_node\_pool\_node\_ephemeral\_os\_disk](#input\_vantiq\_ai\_assistant\_node\_pool\_node\_ephemeral\_os\_disk) | Use of Ephemeral OS Disk for Vantiq ai assistant node pool | `bool` | `true` | no |
| <a name="input_ai_assistant_node_pool_vm_size"></a> [vantiq\_ai\_assistant\_node\_pool\_vm\_size](#input\_vantiq\_ai\_assistant\_node\_pool\_vm\_size) | VM size for Vantiq ai assistant node pool | `string` | `null` | no |
| <a name="input_vantiq_node_pool_node_count"></a> [vantiq\_node\_pool\_node\_count](#input\_vantiq\_node\_pool\_node\_count) | VM count for vantiq node pool | `number` | `1` | no |
| <a name="input_vantiq_node_pool_node_ephemeral_os_disk"></a> [vantiq\_node\_pool\_node\_ephemeral\_os\_disk](#input\_vantiq\_node\_pool\_node\_ephemeral\_os\_disk) | Use of Ephemeral OS Disk for vantiq node pool | `bool` | `true` | no |
| <a name="input_vantiq_node_pool_vm_size"></a> [vantiq\_node\_pool\_vm\_size](#input\_vantiq\_node\_pool\_vm\_size) | VM size for vantiq node pool | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aks_api_endpoint_private_fqdn"></a> [aks\_api\_endpoint\_private\_fqdn](#output\_aks\_api\_endpoint\_private\_fqdn) | n/a |
| <a name="output_aks_client_certificate"></a> [aks\_client\_certificate](#output\_aks\_client\_certificate) | n/a |
| <a name="output_aks_kube_config"></a> [aks\_kube\_config](#output\_aks\_kube\_config) | n/a |
| <a name="output_aks_kube_config_update_command"></a> [aks\_kube\_config\_update\_command](#output\_aks\_kube\_config\_update\_command) | n/a |
| <a name="output_aks_kubernetes_cluster_name"></a> [aks\_kubernetes\_cluster\_name](#output\_aks\_kubernetes\_cluster\_name) | n/a |
| <a name="output_aks_linux_admin_user_name"></a> [aks\_linux\_admin\_user\_name](#output\_aks\_linux\_admin\_user\_name) | n/a |
| <a name="output_aks_linux_ssh_key"></a> [aks\_linux\_ssh\_key](#output\_aks\_linux\_ssh\_key) | n/a |
| <a name="output_aks_network_dns"></a> [aks\_network\_dns](#output\_aks\_network\_dns) | n/a |
| <a name="output_aks_network_plugin"></a> [aks\_network\_plugin](#output\_aks\_network\_plugin) | n/a |
| <a name="output_aks_network_policy"></a> [aks\_network\_policy](#output\_aks\_network\_policy) | n/a |
| <a name="output_aks_network_service_cidr"></a> [aks\_network\_service\_cidr](#output\_aks\_network\_service\_cidr) | n/a |
| <a name="output_aks_nodegroup_grafana_node_count"></a> [aks\_nodegroup\_grafana\_node\_count](#output\_aks\_nodegroup\_grafana\_node\_count) | n/a |
| <a name="output_aks_nodegroup_grafana_vm_size"></a> [aks\_nodegroup\_grafana\_vm\_size](#output\_aks\_nodegroup\_grafana\_vm\_size) | n/a |
| <a name="output_aks_nodegroup_keycloak_node_count"></a> [aks\_nodegroup\_keycloak\_node\_count](#output\_aks\_nodegroup\_keycloak\_node\_count) | n/a |
| <a name="output_aks_nodegroup_keycloak_vm_size"></a> [aks\_nodegroup\_keycloak\_vm\_size](#output\_aks\_nodegroup\_keycloak\_vm\_size) | n/a |
| <a name="output_aks_nodegroup_metric_node_count"></a> [aks\_nodegroup\_metric\_node\_count](#output\_aks\_nodegroup\_metric\_node\_count) | n/a |
| <a name="output_aks_nodegroup_metric_vm_size"></a> [aks\_nodegroup\_metric\_vm\_size](#output\_aks\_nodegroup\_metric\_vm\_size) | n/a |
| <a name="output_aks_nodegroup_mongodb_node_count"></a> [aks\_nodegroup\_mongodb\_node\_count](#output\_aks\_nodegroup\_mongodb\_node\_count) | n/a |
| <a name="output_aks_nodegroup_mongodb_vm_size"></a> [aks\_nodegroup\_mongodb\_vm\_size](#output\_aks\_nodegroup\_mongodb\_vm\_size) | n/a |
| <a name="output_aks_nodegroup_ai_assistant_node_count"></a> [aks\_nodegroup\_vantiq\_ai\_assistant\_node\_count](#output\_aks\_nodegroup\_vantiq\_ai\_assistant\_node\_count) | n/a |
| <a name="output_aks_nodegroup_ai_assistant_vm_size"></a> [aks\_nodegroup\_vantiq\_ai\_assistant\_vm\_size](#output\_aks\_nodegroup\_vantiq\_ai\_assistant\_vm\_size) | n/a |
| <a name="output_aks_nodegroup_vantiq_node_count"></a> [aks\_nodegroup\_vantiq\_node\_count](#output\_aks\_nodegroup\_vantiq\_node\_count) | n/a |
| <a name="output_aks_nodegroup_vantiq_vm_size"></a> [aks\_nodegroup\_vantiq\_vm\_size](#output\_aks\_nodegroup\_vantiq\_vm\_size) | n/a |
| <a name="output_aks_private_cluster_enabled"></a> [aks\_private\_cluster\_enabled](#output\_aks\_private\_cluster\_enabled) | n/a |
| <a name="output_aks_service_principal_id"></a> [aks\_service\_principal\_id](#output\_aks\_service\_principal\_id) | n/a |
| <a name="output_aks_service_principal_password"></a> [aks\_service\_principal\_password](#output\_aks\_service\_principal\_password) | n/a |
