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
  namespace = "istio-system"
  chart = "${path.module}/manifest/base"

  depends_on = [
    var.depends,
  ]
}

resource "helm_release" "istio_control" {
  name      = "istiod"
  namespace = "istio-system"
  timeout   = 300
  chart     = "${path.module}/manifest/istio-control/istio-discovery"

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
  name            = "istio-ingress"
  namespace       = "istio-ingress"
  chart           = "${path.module}/manifest/istio-ingress"
  cleanup_on_fail = true
  force_update    = true

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
