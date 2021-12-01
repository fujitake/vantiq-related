

# Generate random string to be used as service principal password
resource "random_string" "password" {
  count = var.create_service_principal == 0 ? 0 : 1
  length  = 32
  special = true
}

# Create Azure AD Application for Service Principal
resource "azuread_application" "aks" {
  count = var.create_service_principal == 0 ? 0 : 1
  display_name = "${var.aks_cluster_name}-sp"
}

# Create Service Principal
resource "azuread_service_principal" "aks" {
  count = var.create_service_principal == 0 ? 0 : 1
  application_id = azuread_application.aks[0].application_id
}

# Create Service Principal password
resource "azuread_service_principal_password" "aks" {
  count = var.create_service_principal == 0 ? 0 : 1
#  end_date             = "2299-12-30T23:00:00Z"                        # Forever
  service_principal_id = azuread_service_principal.aks[0].id
#  value                = random_string.password[0].result
}

# Grant AKS cluster access to use AKS subnet
resource "azurerm_role_assignment" "aks_lb" {
  count = var.create_service_principal == 0 ? 0 : 1
  principal_id         = azuread_service_principal.aks[0].id
  role_definition_name = "Network Contributor"
  scope                = var.lb_subnet_id
}
# Grant AKS cluster access to use AKS subnet
resource "azurerm_role_assignment" "aks_node_subnet" {
  count = var.create_service_principal == 0 ? 0 : 1
  principal_id         = azuread_service_principal.aks[0].id
  role_definition_name = "Network Contributor"
  scope                = var.aks_node_subnet_id
}
