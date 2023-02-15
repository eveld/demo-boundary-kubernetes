path "kubernetes/creds/my-role" {
  capabilities = ["update", "read"]
}

path "secret/data/kubernetes" {
  capabilities = ["read"]
}
