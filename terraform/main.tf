resource "boundary_scope" "org" {
  scope_id    = "global"
  name        = "hashicorp"
  description = "HashiCorp org"

  auto_create_admin_role   = false
  auto_create_default_role = false
}

resource "boundary_scope" "project" {
  name                     = "devrel"
  description              = "Developer Relations project"
  scope_id                 = boundary_scope.org.id
  auto_create_admin_role   = false
  auto_create_default_role = false
}

resource "boundary_auth_method_password" "org_password" {
  scope_id = boundary_scope.org.id
}
