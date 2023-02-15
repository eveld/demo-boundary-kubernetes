---
sidebar_position: 3
id: kubernetes_vault_1
title: Configuring Vault to Provide Kubernetes Credentials
---

<TerminalVisor>
  <Terminal 
    target="tools.container.shipyard.run" 
    shell="/bin/bash" 
    id="tools" 
    name="Tools"/>

  <Terminal 
    target="local" 
    shell="/bin/bash" 
    id="local" 
    name="Local"/>
</TerminalVisor>

## Create the service account and permissions for vault to use the Kubernetes API

```shell
kubectl apply -f /files/k8s_vault.yaml
```

## Enable and configure the secrets engine

```
vault secrets enable kubernetes
```

Configure Vault with the permission to access kubernetes

```shell
vault write /kubernetes/config \
  kubernetes_host="$(kubectl config view --minify -o 'jsonpath={.clusters[].cluster.server}')" \
  service_account_jwt="$(kubectl get secrets -n vault vault-secret -o json | jq -r .data.token | base64 -d)" \
  kubernetes_ca_cert="$(kubectl get secrets -n vault vault-secret -o json | jq -r '.data."ca.crt"' | base64 -d)" \
  disable_local_ca_jwt="true"
```

## Add the CA to a Vault secret

```shell
vault kv put secret/kubernetes ca=$(kubectl get secrets -n vault vault-secret -o json | jq -r '.data."ca.crt"')
```

## Creating a Role

```shell
vault write kubernetes/roles/my-role \
    allowed_kubernetes_namespaces="*" \
    generated_role_rules="'rules': [{'apiGroups': [''],'resources': ['pods'],'verbs': ['list']}]" \
    token_default_ttl="10m"
```

## Fetching Credentials

```
vault write kubernetes/creds/my-role \
    kubernetes_namespace=vault
```

## Testing

Working has access to `vault` namespace

```
curl -sk $(kubectl config view --minify -o 'jsonpath={.clusters[].cluster.server}')/api/v1/namespaces/vault/pods \
    --header "Authorization: Bearer $(vault write -format=json kubernetes/creds/my-role kubernetes_namespace=vault | jq -r .data.service_account_token)"
```

Not working, does not have access to `default` namespace

```
curl -sk $(kubectl config view --minify -o 'jsonpath={.clusters[].cluster.server}')/api/v1/namespaces/default/pods \
    --header "Authorization: Bearer $(vault write -format=json kubernetes/creds/my-role kubernetes_namespace=vault | jq -r .data.service_account_token)"
```

<div style={{height: "400px"}}/>
