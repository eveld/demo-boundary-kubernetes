container "tools" {
  image   {
    name = "shipyardrun/hashicorp-tools:v0.11.0"
  }
  
  network {
    name = "network.local"
  }

  command = ["tail", "-f", "/dev/null"]
  
  volume {
    source      = "./files"
    destination = "/files"
  }
 
  volume {
    source      = "./config"
    destination = "/boundary/config"
  }

  # Docker sock to be able to to do Docker builds 
  volume {
    source      = "/var/run/docker.sock"
    destination = "/var/run/docker.sock"
  }

  # Shipyard config for Kube 
  volume {
    source      = "${shipyard()}/config/dev"
    destination = "/root/.kube"
  }

  env {
    key = "VAULT_TOKEN"
    value = "root"
  }
  
  env {
    key = "KUBECONFIG"
    value = "/root/.kube/kubeconfig-docker.yaml"
  }
  
  env {
    key = "VAULT_ADDR"
    value = "http://vault.container.shipyard.run:8200"
  }
  
  env {
    key = "BOUNDARY_ADDR"
    value = "http://boundary.container.shipyard.run:9200"
  }
}
