output "aks_client_certificate" {
  value = azurerm_kubernetes_cluster.aks-vantiq.kube_config.0.client_certificate
}

output "aks_kube_config" {
  value = azurerm_kubernetes_cluster.aks-vantiq.kube_config_raw
}

output "aks_kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.aks-vantiq.name
}

output "aks_private_cluster_enabled" {
  value = var.private_cluster_enabled
}

output "aks_kube_config_update_command" {
  value = format("az aks get-credentials --resource-group %s --name %s", azurerm_resource_group.rg-aks.name, element(split("/", azurerm_kubernetes_cluster.aks-vantiq.name), length(split("/", azurerm_kubernetes_cluster.aks-vantiq.name)) - 1))
}

output "aks_service_principal_id" {
  value = var.create_service_principal == false ? "" : azurerm_kubernetes_cluster.aks-vantiq.service_principal[0].client_id
}

output "aks_service_principal_password" {
  value = var.create_service_principal == false ? "" : azurerm_kubernetes_cluster.aks-vantiq.service_principal[0].client_secret
}

output "aks_api_endpoint_private_fqdn" {
  value = azurerm_kubernetes_cluster.aks-vantiq.private_fqdn
}

output "aks_network_dns" {
  value = azurerm_kubernetes_cluster.aks-vantiq.network_profile[0].dns_service_ip
}

output "aks_network_plugin" {
  value = azurerm_kubernetes_cluster.aks-vantiq.network_profile[0].network_plugin
}

output "aks_network_policy" {
  value = azurerm_kubernetes_cluster.aks-vantiq.network_profile[0].network_policy
}

output "aks_network_service_cidr" {
  value = azurerm_kubernetes_cluster.aks-vantiq.network_profile[0].service_cidr
}

output "aks_linux_admin_user_name" {
  value = azurerm_kubernetes_cluster.aks-vantiq.linux_profile[0].admin_username
}

output "aks_linux_ssh_key" {
  value = azurerm_kubernetes_cluster.aks-vantiq.linux_profile[0].ssh_key[0].key_data
}

output "aks_nodegroup_vantiq_vm_size" {
  value = var.vantiq_node_pool_node_count == 0 ? "N/A" : azurerm_kubernetes_cluster_node_pool.vantiqnp[0].vm_size
}

output "aks_nodegroup_vantiq_node_count" {
  value = var.vantiq_node_pool_node_count == 0 ? 0 : azurerm_kubernetes_cluster_node_pool.vantiqnp[0].node_count
}

output "aks_nodegroup_mongodb_vm_size" {
  value = var.mongodb_node_pool_node_count == 0 ? "N/A" : azurerm_kubernetes_cluster_node_pool.mongodbnp[0].vm_size
}

output "aks_nodegroup_mongodb_node_count" {
  value = var.mongodb_node_pool_node_count == 0 ? 0 : azurerm_kubernetes_cluster_node_pool.mongodbnp[0].node_count
}

output "aks_nodegroup_keycloak_vm_size" {
  value = azurerm_kubernetes_cluster.aks-vantiq.default_node_pool[0].vm_size
}

output "aks_nodegroup_keycloak_node_count" {
  value = azurerm_kubernetes_cluster.aks-vantiq.default_node_pool[0].node_count
}

output "aks_nodegroup_grafana_vm_size" {
  value = var.grafana_node_pool_node_count == 0 ? "N/A" : azurerm_kubernetes_cluster_node_pool.grafananp[0].vm_size
}

output "aks_nodegroup_grafana_node_count" {
  value = var.grafana_node_pool_node_count == 0 ? 0 : azurerm_kubernetes_cluster_node_pool.grafananp[0].node_count
}

output "aks_nodegroup_metric_vm_size" {
  value = var.metrics_node_pool_node_count == 0 ? "N/A" : azurerm_kubernetes_cluster_node_pool.metricsnp[0].vm_size
}

output "aks_nodegroup_metric_node_count" {
  value = var.metrics_node_pool_node_count == 0 ? 0 : azurerm_kubernetes_cluster_node_pool.metricsnp[0].node_count
}

output "aks_nodegroup_ai_assistant_vm_size" {
  value = var.ai_assistant_node_pool_node_count == 0 ? "N/A" : azurerm_kubernetes_cluster_node_pool.vantiqaiasnp[0].vm_size
}

output "aks_nodegroup_ai_assistant_node_count" {
  value = var.ai_assistant_node_pool_node_count == 0 ? 0 : azurerm_kubernetes_cluster_node_pool.vantiqaiasnp[0].node_count
}
