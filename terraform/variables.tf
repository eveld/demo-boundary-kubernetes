variable "boundary_address" {
  default = "http://boundary.container.shipyard.run:9200"
}

variable "vault_address" {
  default = "http://vault.container.shipyard.run:8200"
}

variable "vault_token" {
  default = ""
}

variable "kubernetes_config_path" {
  default = ""
}

variable "rift_address" {
  default = ""
}

variable "pagerduty_token" {
  default = ""
}
