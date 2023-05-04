container "postgres" {
  depends_on = ["template.postgres_check"]

  image {
    name = "postgres:15.1"
  }

  port {
    local  = 5432
    host   = 5432
    remote = 5432
  }

  env {
    key   = "POSTGRES_USER"
    value = "postgres"
  }

  env {
    key   = "POSTGRES_PASSWORD"
    value = "postgres"
  }

  env {
    key = "POSTGRES_DB"
    value ="boundary"
  }

  volume {
    source = data("postgres")
    destination = "/files"
  }

  network {
    name = "network.local"
  }
}

template "postgres_check" {
  source = <<EOF
  #!/bin/sh
  until pg_isready -h localhost -p 5432 -U postgres
  do
    echo "Waiting for postgres at: localhost:5432"
    sleep 2;
  done
  EOF
  destination = "${data("postgres")}/check.sh"
}

exec_remote "postgres_readiness_check" {
  depends_on = ["container.postgres"]

  target = "container.postgres"

  cmd = "sh"
  args = [
    "/files/check.sh"
  ]

  network {
    name = "network.local"
  }
}