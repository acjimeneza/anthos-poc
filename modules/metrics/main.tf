terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "kubectl" {
  config_path = var.config_path
}

resource "kubectl_manifest" "yaml_prometheus" {
  yaml_body = "https://raw.githubusercontent.com/istio/istio/release-1.12/samples/addons/prometheus.yaml"
  depends_on = [
    var.depends,
  ]
}


resource "kubectl_manifest" "yaml_grafana" {
  yaml_body = "https://raw.githubusercontent.com/istio/istio/release-1.12/samples/addons/grafana.yaml"
  depends_on = [
    kubectl_manifest.yaml_prometheus,
  ]
}
