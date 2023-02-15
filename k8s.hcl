k8s_cluster "dev" {
  driver  = "k3s" # default

  nodes = 1 # default

  network {
    name = "network.local"
  }
}

output "KUBECONFIG" {
  value = k8s_config("dev")
}
