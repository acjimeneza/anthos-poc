variable "config_path" {
    type = string
    description = "Path of the configuration file"
    default = "./config"
}

variable "depends" {
    description = "Dependency to create the monitor services"
}