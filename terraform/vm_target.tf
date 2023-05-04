resource "boundary_target" "vm" {
  name     = "vm"
  scope_id = boundary_scope.project.id
  type     = "tcp"

  address      = "vm.container.shipyard.run"
  default_port = 22
}

resource "boundary_role" "vm" {
  name           = "vm-access"
  scope_id       = boundary_scope.project.id
  grant_scope_id = boundary_scope.project.id

  grant_strings = [
    "id=${boundary_target.vm.id};actions=authorize-session"
  ]

  principal_ids = [
    boundary_user.boundary_admin.id,
    boundary_user.erik.id
  ]
}
