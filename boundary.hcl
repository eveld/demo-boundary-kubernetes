network "local" {
    subnet = "10.0.0.0/16"
}

container "boundary_db" {
  network {
      name = "network.local"
  }

  image {
      name = "postgres:15.1"
  }

  env {
    key = "POSTGRES_USER"
    value = "postgres"
  }

  env {
    key = "POSTGRES_PASSWORD"
    value = "postgres"
  }

  env {
    key = "POSTGRES_DB"
    value ="boundary"
  }

  port {
    host   = 5432
    local  = 5432
    remote = 5432
  }
}

template "boundary_init" {
  source = <<-EOF
    #! /bin/sh

    command="boundary database init -config /boundary/config/boundary_server.hcl -skip-auth-method-creation -skip-host-resources-creation -skip-scopes-creation -skip-target-creation"

    # Wait until the database can be contacted
    while ! $command
    do
      echo "waiting for db server"
      sleep 10
    done
  EOF

  destination = "${data("temp")}/boundary_init.sh"
}

exec_remote "boundary_init" {
  depends_on = ["container.boundary_db", "template.boundary_init"]

  image {
      name = "hashicorp/boundary:0.12"
  }
  
  network {
    name = "network.local"
  }

  cmd = "sh"
  args = [
    "/files/boundary_init.sh"
  ]
  
  volume {
    source = "./config"
    destination = "/boundary/config"
  }
  
  volume {
    source = data("temp")
    destination = "/files"
  }
}

container "boundary" {
  depends_on = ["exec_remote.boundary_init"]

  network {
    name = "network.local"
    ip_address = "10.0.0.200"
  }

  image {
      name = "hashicorp/boundary:0.12"
  }

  command = ["boundary", "server", "-config", "/boundary/config/boundary_server.hcl"]

  volume {
    source = "./config"
    destination = "/boundary/config"
  }
  
  volume {
    source = "."
    destination = "/files"
  }

  port {
    host   = 9200
    local  = 9200
    remote = 9200
  }
  
  port {
    host   = 9201
    local  = 9201
    remote = 9201
  }
  
  port {
    host   = 9202
    local  = 9202
    remote = 9202
  }
}
