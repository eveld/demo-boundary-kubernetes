output "org_auth_method_id" {
  value       = boundary_auth_method_password.org_password.id
  description = "Auth method ID for Boundary Org authentication"
}

output "org" {
  value = boundary_scope.org.id
}

output "project" {
  value = boundary_scope.project.id
}

output "erik_username" {
  value       = boundary_account_password.erik.login_name
  description = "Erik's username for Boundary authentication"
}

output "erik_password" {
  value       = boundary_account_password.erik.password
  description = "Erik's password for Boundary authentication"
  sensitive   = true
}

output "target_id" {
  value       = boundary_target.kubernetes.id
  description = "Target ID for Boundary session"
}

output "admin_username" {
  value       = boundary_account_password.boundary_admin.login_name
  description = "Admin username for Boundary authentication"
}

output "admin_password" {
  value       = boundary_account_password.boundary_admin.password
  description = "Admin password for Boundary authentication"
  sensitive   = true
}

output "vault_username" {
  value       = boundary_account_password.vault.login_name
  description = "Vault username for Boundary authentication"
}

output "vault_password" {
  value       = boundary_account_password.vault.password
  description = "Vault password for Boundary authentication"
  sensitive   = true
}

output "rift_username" {
  value       = boundary_account_password.rift.login_name
  description = "Rift username for Boundary authentication"
}

output "rift_password" {
  value       = boundary_account_password.rift.password
  description = "Rift password for Boundary authentication"
  sensitive   = true
}

output "pagerduty_token" {
  value     = var.pagerduty_token
  sensitive = true
}
