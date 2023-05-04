resource "boundary_role" "global_anon_listing" {
  scope_id = "global"

  grant_strings = [
    "id=*;type=auth-method;actions=list,authenticate",
    "id=*;type=scope;actions=list,read",
    "id={{account.id}};actions=read,change-password"
  ]

  principal_ids = [
    "u_anon"
  ]
}

resource "boundary_role" "org_anon_listing" {
  scope_id = boundary_scope.org.id

  grant_strings = [
    "id=*;type=auth-method;actions=list,authenticate",
    "type=scope;actions=list",
    "id={{account.id}};actions=read,change-password"
  ]

  principal_ids = [
    "u_anon"
  ]
}

resource "boundary_role" "boundary_org_admin" {
  name           = "hashicorp-admin"
  description    = "admin role for organization"
  scope_id       = boundary_scope.org.id
  grant_scope_id = boundary_scope.org.id

  grant_strings = [
    "id=*;type=*;actions=*"
  ]

  principal_ids = [
    boundary_user.boundary_admin.id
  ]
}

resource "boundary_role" "readonly" {
  name        = "hashicorp-readonly"
  description = "read-only role for organization"

  grant_strings = [
    "id=*;type=*;actions=read",
    "id=*;type=target;actions=read,list,authorize-session",
    "id=*;type=session;actions=read,list"
  ]
  scope_id       = boundary_scope.org.id
  grant_scope_id = boundary_scope.org.id

  principal_ids = [
    boundary_group.app.id,
    boundary_user.vault.id,
    boundary_user.rift.id
  ]
}

resource "boundary_role" "project_readonly" {
  name        = "devrel-readonly"
  description = "read-only role for project"

  grant_strings = [
    "id=*;type=*;actions=read",
    "id=*;type=target;actions=read,list",
    "id=*;type=session;actions=read,list",
  ]
  scope_id       = boundary_scope.project.id
  grant_scope_id = boundary_scope.project.id

  principal_ids = [
    boundary_user.erik.id,
  ]
}

resource "boundary_role" "boundary_project_admin" {
  name           = "hashiconf-admin"
  scope_id       = boundary_scope.project.id
  grant_scope_id = boundary_scope.project.id

  grant_strings = [
    "id=*;type=*;actions=*"
  ]

  principal_ids = [
    boundary_user.boundary_admin.id,
    boundary_user.vault.id,
    boundary_user.rift.id
  ]
}
