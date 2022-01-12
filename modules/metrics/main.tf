terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    curl = {
      source  = "anschoewe/curl"
      version = "0.1.3"
    }
  }
}

provider "kubectl" {
  config_path = var.config_path
}


locals {
  yaml_prometheus = toset(compact(split("---", file("${path.cwd}/prometheus.yaml")), ))
  yaml_grafana = toset(compact(split("---", file("${path.cwd}/grafana.yaml"))))
}

resource "kubectl_manifest" "yaml_prometheus" {
  for_each = local.yaml_prometheus
  yaml_body = each.value

  depends_on = [
    var.depends,
  ]
}

resource "kubectl_manifest" "yaml_grafana" {
  for_each = local.yaml_grafana
  yaml_body = each.value

  depends_on = [
    kubectl_manifest.yaml_prometheus,
  ]
}
