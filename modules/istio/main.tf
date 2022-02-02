terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.4.1"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = var.config_path
  }
}

resource "helm_release" "istio_base" {
  name              = "istio-base"
  repository        = "https://istio-release.storage.googleapis.com/charts"
  chart             = "base"
  dependency_update = true
  version           = "1.12.1"
  namespace         = "istio-system"

  cleanup_on_fail = true
  force_update    = true

  depends_on = [
    var.depends,
  ]
}

resource "helm_release" "istio_control" {
  name              = "istiod"
  repository        = "https://istio-release.storage.googleapis.com/charts"
  chart             = "istiod"
  dependency_update = true
  version           = "1.12.1"
  namespace         = "istio-system"

  cleanup_on_fail = true
  force_update    = true

  # Resources for sidecar
  values = [
    <<EOT
global:
  proxy:
    resources:
      requests:
        cpu: ${var.sidecar_request_cpu}
        memory: ${var.sidecar_request_memory}
      limits:
        cpu: ${var.sidecar_limit_cpu}
        memory: ${var.sidecar_limit_memory}
EOT
  ]
  depends_on = [
    helm_release.istio_base,
  ]
}

resource "helm_release" "istio_ingress" {
  name              = "istio-ingress"
  repository        = "https://istio-release.storage.googleapis.com/charts"
  chart             = "gateway"
  dependency_update = true
  version           = "1.12.1"

  namespace       = "istio-ingress"
  cleanup_on_fail = true
  force_update    = true

  # Resources for istio ingress
  values = [
    <<EOT
labels:
  app: istio-ingressgateway
  istio: ingressgateway
resources:
  requests:
    cpu: ${var.ingressgateway_request_cpu}
    memory: ${var.ingressgateway_request_memory}
  limits:
    cpu: ${var.ingressgateway_limit_cpu}
    memory: ${var.ingressgateway_limit_memory}

autoscaling:
  minReplicas: ${var.ingressgateway_autoscale_min}
  maxReplicas: ${var.ingressgateway_autoscale_max}
EOT
  ]
  depends_on = [
    helm_release.istio_control,
  ]
}
