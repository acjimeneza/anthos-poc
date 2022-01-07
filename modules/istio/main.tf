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
  name = "istio-base"
  # repository = "https://istio-release.storage.googleapis.com/charts"
  # chart      = "base"
  # dependency_update = true
  namespace = "istio-system"
  # version = "1.12.1"
  chart = "${path.module}/manifest/base"

  depends_on = [
    var.depends,
  ]
}

resource "helm_release" "istio_control" {
  name = "istiod"
  # repository = "https://istio-release.storage.googleapis.com/charts"
  # chart      = "istiod"
  # dependency_update = true
  namespace = "istio-system"
  # version = "1.12.1"
  timeout = 300
  chart   = "${path.module}/manifest/istio-control/istio-discovery"

  # Resources for sidecar
  set {
    name  = "global.proxy.resources.requests.cpu"
    value = var.sidecar_request_cpu
  }

  set {
    name  = "global.proxy.resources.requests.memory"
    value = var.sidecar_request_memory
  }
  set {
    name  = "global.proxy.resources.limits.cpu"
    value = var.sidecar_limit_cpu
  }
  set {
    name  = "global.proxy.resources.limits.memory"
    value = var.sidecar_limit_memory
  }

  depends_on = [
    helm_release.istio_base,
  ]
}

resource "helm_release" "istio_ingress" {
  name = "istio-ingress"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  dependency_update = true
  version = "1.12.1"

  namespace       = "istio-ingress"
  # chart           = "${path.module}/manifest/istio-ingress"
  cleanup_on_fail = true
  force_update    = true

  # Resources for istio ingress
  # set {
  #   name  = "gateways.istio-ingressgateway.autoscaleMin"
  #   value = var.ingressgateway_autoscale_min
  # }
  # set {
  #   name  = "gateways.istio-ingressgateway.autoscaleMax"
  #   value = var.ingressgateway_autoscale_max
  # }
  # set {
  #   name  = "gateways.istio-ingressgateway.resources.requests.cpu"
  #   value = var.ingressgateway_request_cpu
  # }
  # set {
  #   name  = "gateways.istio-ingressgateway.resources.requests.memory"
  #   value = var.ingressgateway_request_memory
  # }
  # set {
  #   name  = "gateways.istio-ingressgateway.resources.limits.cpu"
  #   value = var.ingressgateway_limit_cpu
  # }
  # set {
  #   name  = "gateways.istio-ingressgateway.resources.limits.memory"
  #   value = var.ingressgateway_limit_memory
  # }
  values = [
    <<EOT
gateways:
  istio-ingressgateway:
    autoscaleMin: ${var.ingressgateway_autoscale_min}
    autoscaleMax: ${var.ingressgateway_autoscale_max}
    resources:
      requests:
        cpu: ${var.ingressgateway_request_cpu}
        memory: ${var.ingressgateway_request_memory}
      limits:
        cpu: ${var.ingressgateway_limit_cpu}
        memory: ${var.ingressgateway_limit_memory}
EOT
  ]
  depends_on = [
    helm_release.istio_control,
  ]
}
