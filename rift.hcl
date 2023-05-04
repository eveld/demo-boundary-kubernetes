template "rift_config" {
  source = <<EOT
  #!/bin/bash
  ORGANIZATION=$(terraform -chdir=/terraform output -raw org)
  SCOPE=$(terraform -chdir=/terraform output -raw project)
  PAGERDUTY_TOKEN=$(terraform -chdir=/terraform output -raw pagerduty_token)
  AUTH_METHOD=$(terraform -chdir=/terraform output -raw org_auth_method_id)
  USERNAME=$(terraform -chdir=/terraform output -raw rift_username)
  PASSWORD=$(terraform -chdir=/terraform output -raw rift_password)
  cat <<EOF > /rift/config.json
{
  "log": {
    "level": "debug"
  },
  "alertmanager": {
    "enabled": true
  },
  "pagerduty": {
    "enabled": true,
    "token": "$${PAGERDUTY_TOKEN}"
  },
  "boundary": {
    "organization": "$${ORGANIZATION}",
    "scope": "$${SCOPE}",
    "auth": {
      "method": "$${AUTH_METHOD}",
      "username": "$${USERNAME}",
      "password": "$${PASSWORD}"
    }
  }
}
EOF
  EOT
  destination = "${data("rift")}/generate.sh"
}

exec_remote "rift_config" {
  depends_on = ["exec_remote.boundary_setup", "template.rift_config"]
  
  image {
    name = "shipyardrun/hashicorp-tools:v0.10.0"
  }

  cmd = "/bin/bash"
  args = [
    "/rift/generate.sh"
  ]

  volume {
    source = "./terraform"
    destination = "/terraform"
  }

  volume {
    source = "${data("rift")}"
    destination = "/rift"
  }
}

container "rift" {
  depends_on = ["exec_remote.rift_config"]

  image {
    name = "hashicraft/rift:v0.3.2"
  }
  
  command = [
    "--config-file=/config/config.json"
  ]

  port {
    local  = 4444
    remote = 4444
    host = 4444
  }

  env {
    key = "BOUNDARY_ADDRESS"
    value = "http://boundary.container.shipyard.run:9200"
  }

  volume {
    source = "${data("rift")}"
    destination = "/config"
  }

  network {
    name = "network.local"
  }
}