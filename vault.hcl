
variable "vault_network" {
  default = "local"
}

module "vault" {
  source = "github.com/shipyard-run/blueprints/modules//vault-dev"
}
