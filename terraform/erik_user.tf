resource "boundary_account_password" "erik" {
  auth_method_id = boundary_auth_method_password.org_password.id
  type           = "password"
  login_name     = "erik"
  password       = "password"
}

resource "boundary_user" "erik" {
  name        = "erik"
  description = "Just an ordinary user"
  account_ids = [boundary_account_password.erik.id]
  scope_id    = boundary_scope.org.id
}

resource "boundary_group" "app" {
  name        = "app"
  description = "Group for app incident response workflow"
  member_ids  = [boundary_user.erik.id]
  scope_id    = boundary_scope.project.id
}
