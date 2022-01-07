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

data "curl" "get_yaml_prometheus" {
  uri         = "https://raw.githubusercontent.com/istio/istio/release-1.12/samples/addons/prometheus.yaml"
  http_method = "GET"
  depends_on = [
    var.depends,
  ]
}

data "curl" "get_yaml_grafana" {
  uri         = "https://raw.githubusercontent.com/istio/istio/release-1.12/samples/addons/grafana.yaml"
  http_method = "GET"
  depends_on = [
    data.curl.get_yaml_prometheus,
  ]
}

locals {
  yaml_prometheus = toset(compact(split("---","${data.curl.get_yaml_prometheus.response}"), ))
  yaml_grafana = toset(compact(split("---","${data.curl.get_yaml_grafana.response}")))
}

resource "kubectl_manifest" "yaml_prometheus" {
  for_each = local.yaml_prometheus
  yaml_body = each.value

  depends_on = [
    data.curl.get_yaml_grafana,
  ]
}

resource "kubectl_manifest" "yaml_grafana" {
  for_each = local.yaml_grafana
  yaml_body = each.value

  depends_on = [
    kubectl_manifest.yaml_prometheus,
  ]
}
