terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.7.1"
    }
  }
}

provider "kubernetes" {
  config_path = var.config_path
}

resource "kubernetes_namespace" "istio-system" {
  metadata {
    name = "istio-system"
  }

  depends_on = [
    var.depends,
  ]
}

resource "kubernetes_namespace" "test-services" {
  metadata {
    labels = {
      istio-injection = "enabled"
    }
    name = "test-services"
  }
  depends_on = [
    kubernetes_namespace.istio-system,
  ]
}

resource "kubernetes_namespace" "istio-ingress" {
  metadata {
    labels = {
      istio-injection = "enabled"
    }
    name = "istio-ingress"
  }
  depends_on = [
    kubernetes_namespace.test-services,
  ]
}
