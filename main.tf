#this resource is for creating resource group
resource "azurerm_resource_group" "kube-rg" {
  name     = "kube-rg-alpha"
  location = "West US"
}

/* this resource is for creating azure container registry in the above RG*/
resource "azurerm_container_registry" "acr_acr" {
  name                = "acr00999"
  resource_group_name = azurerm_resource_group.kube-rg.name
  location            = azurerm_resource_group.kube-rg.location
  sku                 = "Basic"
}

/* this resource is for creating AK8S CLUSTER in the above RG*/
resource "azurerm_kubernetes_cluster" "acr_aks" {
  name                = "acraks1"
  location            = azurerm_resource_group.kube-rg.location
  resource_group_name = azurerm_resource_group.kube-rg.name
  dns_prefix          = "acraks1"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

/* this resource is for attaching ACR to AK8S CLUSTER i*/
resource "azurerm_role_assignment" "acr_aks_role" {
  principal_id                     = azurerm_kubernetes_cluster.acr_aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr_acr.id
  skip_service_principal_aad_check = true
}