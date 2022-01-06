variable "client_id" {
    default = "SystemAssigned"
}
# variable "client_secret" {}

variable "agent_count" {
  default = 1
}

variable "max_agent_count" {
  default = 2
}

variable "min_agent_count" {
  default = 1
}

variable "pod_count" {
  default = 30
}

variable "dns_prefix" {
  default = "k8stest"
}

variable "cluster_name" {
  default = "k8stest"
}

variable "resource_group_name" {
  default = "azure-k8stest"
}

variable "location" {
  default = "eastus2"
}

variable "k8s_version" {
  default = "1.21.7"
}

variable "enable_auto_scaling" {
  default = true
}