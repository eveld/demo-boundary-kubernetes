resource "boundary_account_password" "vault" {
  auth_method_id = boundary_auth_method_password.org_password.id
  type           = "password"
  login_name     = "vault"
  password       = random_password.vault.result
}

resource "boundary_user" "vault" {
  name        = "vault"
  description = "Vault user"
  account_ids = [boundary_account_password.vault.id]
  scope_id    = boundary_scope.org.id
}

resource "random_password" "vault" {
  length      = 16
  special     = false
  min_numeric = 1
  min_lower   = 1
  min_upper   = 1
}
