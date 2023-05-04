resource "vault_policy" "boundary_controller" {
  name = "boundary-controller"

  policy = <<EOT
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/revoke-self" {
  capabilities = ["update"]
}

path "sys/leases/renew" {
  capabilities = ["update"]
}

path "sys/leases/revoke" {
  capabilities = ["update"]
}

path "sys/capabilities-self" {
  capabilities = ["update"]
}
EOT
}

resource "vault_token" "boundary_credential_store" {
  policies = [vault_policy.boundary_controller.name]

  no_parent = true
  renewable = true
  ttl       = "24h"
  period    = "30m"
}

resource "boundary_credential_store_vault" "vault" {
  name        = "vault"
  description = "Vault credential store"
  address     = var.vault_address
  token       = vault_token.boundary_credential_store.client_token
  scope_id    = boundary_scope.project.id
}
