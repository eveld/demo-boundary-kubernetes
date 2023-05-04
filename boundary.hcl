network "local" {
    subnet = "10.0.0.0/16"
}

template "boundary_config" {
  source = file("files/boundary-server.hcl")
  destination = "${data("boundary")}/config.hcl"
}

exec_remote "boundary_init" {
  image  {
    name = "hashicorp/boundary:0.12"
  }

  cmd = "boundary"
  args = [
    "database",
    "init",
    "-skip-target-creation",
    "-skip-scopes-creation",
    "-skip-host-resources-creation",
    "-skip-auth-method-creation",
    "-config=/boundary/config.hcl"
  ]

  env {
    key = "BOUNDARY_POSTGRES_URL"
    value = "postgresql://postgres:postgres@postgres.container.shipyard.run:5432/boundary?sslmode=disable"
  }

  network {
      name = "network.local"
  }

  volume {
    source = data("boundary")
    destination = "/boundary"
  }

  depends_on = [
    "template.boundary_config",
    "container.postgres",
    "exec_remote.postgres_readiness_check"
  ]
}

container "boundary" {
  image  {
    name = "hashicorp/boundary:0.12"
  }

  command = [
    "boundary",
    "server",
    "-config=/boundary/config.hcl"
  ]

  port {
    local = 9200
    remote = 9200
    host = 9200
  }

  port {
    local = 9201
    remote = 9201
    host = 9201
  }

  port {
    local = 9202
    remote = 9202
    host = 9202
  }

  privileged = true

  env {
    key   = "BOUNDARY_POSTGRES_URL"
    value = "postgresql://postgres:postgres@postgres.container.shipyard.run:5432/boundary?sslmode=disable"
  }

  env {
    key   = "BOUNDARY_ADDR"
    value = "http://localhost:9200"
  }

  network {
    name = "network.local"
    ip_address = "10.0.0.200"
  }

  volume {
    source = data("boundary")
    destination = "/boundary"
  }
  
  depends_on = [
    "template.boundary_config",
    "exec_remote.boundary_init",
    "exec_remote.postgres_readiness_check"
  ]
}

template "boundary_setup" {
  source = <<EOT
  #!/bin/bash
  terraform -chdir=/terraform init
  terraform -chdir=/terraform destroy -auto-approve
  terraform -chdir=/terraform apply -auto-approve
  
  EOT
  destination = "${data("boundary")}/setup.sh"
}

exec_remote "boundary_setup" {
  image {
    name = "shipyardrun/hashicorp-tools:v0.10.0"
  }

  cmd = "/bin/bash"
  args = [
    "/setup.sh"
  ]

  env {
    key = "TF_VAR_kubernetes_config_path"
    value = "/k8s/config"
  }

  env {
    key = "TF_VAR_vault_token"
    value = var.vault_token
  }

  env {
    key = "TF_VAR_pagerduty_token"
    value = var.pagerduty_token
  }

  env {
    key = "TF_VAR_rift_address"
    value = var.rift_address
  }

  volume {
    source = "${data("boundary")}/setup.sh"
    destination = "/setup.sh"
  }

   volume {
    source = k8s_config_docker("dev")
    destination = "/k8s/config"
  }

  volume {
    source = "${file_dir()}/terraform"
    destination = "/terraform"
  }

  network {
    name = "network.local"
  }

  depends_on = [
    "template.boundary_setup",
    "container.boundary"
  ]
}

variable "pagerduty_token" {
  default = ""
}

variable "rift_address" {
  default = ""
}