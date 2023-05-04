data "kubernetes_service_v1" "kubernetes" {
  metadata {
    name = "kubernetes"
  }
}

resource "boundary_target" "kubernetes" {
  name     = "kubernetes"
  scope_id = boundary_scope.project.id
  type     = "tcp"

  address      = "server.dev.k8s-cluster.shipyard.run"
  default_port = data.kubernetes_service_v1.kubernetes.spec.0.port.0.target_port
}
