variable "config_path" {
    type = string
    description = "Path of the configuration file"
    default = "./config"
}

variable "depends" {
    description = "Dependency to execute helm charts"
}

variable "sidecar_request_cpu" {
    type = string
    description = "CPU resource request for the sidecar"
    default = "100m"
}

variable "sidecar_request_memory" {
    type = string
    description = "Memory resource request for the sidecar"
    default = "128Mi"
}

variable "sidecar_limit_cpu" {
    type = string
    description = "CPU resource limit for the sidecar"
    default = "200m"
}
variable "sidecar_limit_memory" {
    type = string
    description = "Memory resource limit for the sidecar"
    default = "256Mi"
}

variable "ingressgateway_autoscale_min" {
  type = number
  description = "Autoscale Min instances"
  default = 1
}

variable "ingressgateway_autoscale_max" {
  type = number
  description = "Autoscale Max instances"
  default = 2
}

variable "ingressgateway_request_cpu" {
    type = string
    description = "CPU resource request for the ingressgateway"
    default = "100m"
}

variable "ingressgateway_request_memory" {
    type = string
    description = "Memory resource request for the ingressgateway"
    default = "128Mi"
}

variable "ingressgateway_limit_cpu" {
    type = string
    description = "CPU resource limit for the ingressgateway"
    default = "1000m"
}
variable "ingressgateway_limit_memory" {
    type = string
    description = "Memory resource limit for the ingressgateway"
    default = "1024Mi"
}