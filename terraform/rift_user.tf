resource "boundary_account_password" "rift" {
  auth_method_id = boundary_auth_method_password.org_password.id
  type           = "password"
  login_name     = "rift"
  password       = random_password.rift.result
}

resource "boundary_user" "rift" {
  name        = "rift"
  description = "Rift user"
  account_ids = [boundary_account_password.rift.id]
  scope_id    = boundary_scope.org.id
}

resource "random_password" "rift" {
  length      = 16
  special     = false
  min_numeric = 1
  min_lower   = 1
  min_upper   = 1
}
