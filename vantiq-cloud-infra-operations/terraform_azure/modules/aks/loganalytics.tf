
# LogAnalyticsワークスペースの有効化
resource "azurerm_log_analytics_workspace" "k8s" {
  count = var.loganalytics_enabled == true ? 1 : 0
  name                = "${var.aks_cluster_name}-log"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-aks.name
  sku                 = var.log_analytics_workspace_sku
}

# ContainerInsightsを有効化してLogAnalyticsにデータを送信する
resource "azurerm_log_analytics_solution" "k8s" {
  count = var.loganalytics_enabled == true ? 1 : 0
  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg-aks.name
  workspace_resource_id = azurerm_log_analytics_workspace.k8s[0].id
  workspace_name        = azurerm_log_analytics_workspace.k8s[0].name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
