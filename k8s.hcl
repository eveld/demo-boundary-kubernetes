k8s_cluster "dev" {
  driver  = "k3s"

  nodes = 1

  network {
    name = "network.local"
  }
}

output "KUBECONFIG" {
  value = k8s_config("dev")
}

output "KUBE_CONFIG_PATH" {
  value = k8s_config("dev")
}
