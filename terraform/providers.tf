terraform {
  required_providers {
    boundary = {
      source  = "hashicorp/boundary"
      version = "1.1.4"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.19.0"
    }

    pagerduty = {
      source  = "pagerduty/pagerduty"
      version = "2.11.2"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "3.14.0"
    }
  }
}

provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}

provider "kubernetes" {
  config_path = var.kubernetes_config_path
}

provider "pagerduty" {
  token = var.pagerduty_token

}

provider "boundary" {
  addr             = var.boundary_address
  recovery_kms_hcl = <<EOT
  kms "aead" {
    purpose   = "recovery"
    aead_type = "aes-gcm"
    key       = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
    key_id    = "global_recovery"
  }
  EOT
}
