terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rgTerraformState"
    storage_account_name = "saqaterraformstate2"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Resource group
resource "azurerm_resource_group" "k8s" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Networks

resource "azurerm_virtual_network" "vn" {
  name                = "${var.cluster_name}-vnet"
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  address_space       = ["192.168.0.0/16"]
  depends_on = [
    azurerm_resource_group.k8s,
  ]
}

resource "azurerm_subnet" "sn" {
  name                 = "${var.cluster_name}-subnet"
  resource_group_name  = azurerm_resource_group.k8s.name
  address_prefixes     = ["192.168.8.0/21"]
  virtual_network_name = azurerm_virtual_network.vn.name
  depends_on = [
    azurerm_virtual_network.vn,
  ]
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.k8s_version

  default_node_pool {
    name                = "agentpool"
    node_count          = var.agent_count
    min_count           = var.min_agent_count
    max_count           = var.max_agent_count
    enable_auto_scaling = var.enable_auto_scaling
    vm_size             = "Standard_B4ms"
    max_pods            = var.pod_count
    vnet_subnet_id      = azurerm_subnet.sn.id
  }

  identity {
    type = var.client_id
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet"
  }

  tags = {
    Environment = "Development"
  }

  depends_on = [
    azurerm_subnet.sn,
  ]
}

resource "local_file" "kube-config" {
  content  = azurerm_kubernetes_cluster.k8s.kube_config_raw
  filename = "${path.cwd}/config"
  depends_on = [
    azurerm_kubernetes_cluster.k8s,
  ]
}

module "namespaces" {
  source      = "./modules/namespaces"
  config_path = "${path.cwd}/config"
  depends     = local_file.kube-config
}

module "istio" {
  source      = "./modules/istio"
  config_path = "${path.cwd}/config"
  depends     = module.namespaces

  # Istio controler and discovery variables
  sidecar_request_cpu    = "100m"
  sidecar_request_memory = "128Mi"
  sidecar_limit_cpu      = "200m"
  sidecar_limit_memory   = "256Mi"

  # Istio ingress variables
  ingressgateway_autoscale_min  = 1
  ingressgateway_autoscale_max  = 3
  ingressgateway_request_cpu    = "100m"
  ingressgateway_request_memory = "128Mi"
  ingressgateway_limit_cpu      = "1200m"
  ingressgateway_limit_memory   = "1024Mi"
}

module "metrics" {
  source      = "./modules/metrics"
  config_path = "${path.cwd}/config"
  depends     = module.istio
}
