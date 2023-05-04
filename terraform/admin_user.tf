resource "boundary_account_password" "boundary_admin" {
  auth_method_id = boundary_auth_method_password.org_password.id
  type           = "password"
  login_name     = "admin"
  password       = "password"
}

resource "boundary_user" "boundary_admin" {
  name        = "admin"
  description = "Admin user"
  account_ids = [boundary_account_password.boundary_admin.id]
  scope_id    = boundary_scope.org.id
}
