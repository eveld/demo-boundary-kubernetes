---
sidebar_position: 4
id: kubernetes_vault_2
title: Configuring Boundary to allow access to Kubernetes
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

## Add the Vault policy

```shell
vault policy write boundary-controller /files/boundary-controller-policy.hcl
vault policy write kubernetes-auth /files/kubernetes-policy.hcl
```

## Test a token can read the kubernetes creds

```shell
vault token create \
  -period=30m \
  -orphan=true \
  -policy=boundary-controller \
  -policy=kubernetes-auth \
  -no-default-policy=true \
  -renewable=true
```

```
VAULT_TOKEN="$(vault token create -period=30m -format=json -orphan=true -policy=boundary-controller -policy=kubernetes-auth -no-default-policy=true -renewable=true | jq -r .auth.client_token)" vault write kubernetes/creds/my-role kubernetes_namespace=vault
```

## Create a Credentials Store for Vault

```shell
boundary credential-stores create vault \
  -scope-id "p_f0Aa554tqQ" \
  -recovery-config /boundary/config/boundary_server.hcl \
  -vault-address "http://vault.container.shipyard.run:8200" \
  -vault-token "$(vault token create -period=30m -format=json -orphan=true -policy=boundary-controller -policy=kubernetes-auth -no-default-policy=true -renewable=true | jq -r .auth.client_token)"
```

```
Credential Store information:
  Created Time:        Wed, 15 Feb 2023 12:55:49 UTC
  ID:                  csvlt_keXno6UqCe
  Type:                vault
  Updated Time:        Wed, 15 Feb 2023 12:55:49 UTC
  Version:             1
```

## Create the Credentials Libraries

First the dynamic access credentials

```shell
boundary credential-libraries create vault \
    -credential-store-id csvlt_keXno6UqCe \
    -recovery-config /boundary/config/boundary_server.hcl \
    -vault-path "kubernetes/creds/my-role" \
    -vault-http-method="POST" \
    -vault-http-request-body="{\"kubernetes_namespace\": \"vault\",\"ttl\": \"1h\"}" \
    -name "kubernetes vault admin"
```

```shell
Credential Library information:
  Created Time:          Wed, 15 Feb 2023 14:34:20 UTC
  Credential Store ID:   csvlt_keXno6UqCe
  ID:                    clvlt_KwmY5lhNX0
  Name:                  kubernetes vault admin
  Type:                  vault-generic
  Updated Time:          Wed, 15 Feb 2023 14:34:20 UTC
  Version:               1
```

Then the ca

```shell
boundary credential-libraries create vault \
    -credential-store-id csvlt_keXno6UqCe \
    -recovery-config /boundary/config/boundary_server.hcl \
    -vault-path "secret/data/kubernetes" \
    -name "kubernetes vault ca"
```

```shell
Credential Library information:
  Created Time:          Wed, 15 Feb 2023 13:34:25 UTC
  Credential Store ID:   csvlt_keXno6UqCe
  ID:                    clvlt_vOxnF0iBlW
  Name:                  kubernetes vault ca
  Type:                  vault-generic
  Updated Time:          Wed, 15 Feb 2023 13:34:25 UTC
  Version:               1
```

## Create the target

```shell
boundary targets create tcp \
   -recovery-config /boundary/config/boundary_server.hcl \
   -name="kubernetes" \
   -description="Access to the Kubernetes API" \
   -default-port="$(kubectl config view --minify -o 'jsonpath={.clusters[].cluster.server}' | sed 's/https:\/\/\(.*\):\(.*\)/\2/')" \
   -address="$(kubectl config view --minify -o 'jsonpath={.clusters[].cluster.server}' | sed 's/https:\/\/\(.*\):\(.*\)/\1/')" \
   -scope-id=p_f0Aa554tqQ
```

```shell
Target information:
  Address:                    server.dev.k8s-cluster.shipyard.run
  Created Time:               Wed, 15 Feb 2023 11:48:06 UTC
  Description:                Access to the Kubernetes API
  ID:                         ttcp_FZ2bhOwmle
  Name:                       kubernetes
  Session Connection Limit:   -1
  Session Max Seconds:        28800
  Type:                       tcp
  Updated Time:               Wed, 15 Feb 2023 11:48:06 UTC
  Version:                    1
```

## Add the Credentials to the target

```shell
boundary targets add-credential-sources \
  -recovery-config /boundary/config/boundary_server.hcl \
  -id=ttcp_FZ2bhOwmle \
  -application-credential-source=clvlt_KwmY5lhNX0
```

```
Target information:
  Address:                    server.dev.k8s-cluster.shipyard.run
  Created Time:               Wed, 15 Feb 2023 11:48:06 UTC
  Description:                Access to the Kubernetes API
  ID:                         ttcp_FZ2bhOwmle
  Name:                       kubernetes
  Session Connection Limit:   -1
  Session Max Seconds:        28800
  Type:                       tcp
  Updated Time:               Wed, 15 Feb 2023 13:00:35 UTC
  Version:                    2
```


```shell
boundary targets add-credential-sources \
  -recovery-config /boundary/config/boundary_server.hcl \
  -id=ttcp_FZ2bhOwmle \
  -application-credential-source=clvlt_vOxnF0iBlW
```

```shell
Target information:
  Address:                    server.dev.k8s-cluster.shipyard.run
  Created Time:               Wed, 15 Feb 2023 11:48:06 UTC
  Description:                Access to the Kubernetes API
  ID:                         ttcp_FZ2bhOwmle
  Name:                       kubernetes
  Session Connection Limit:   -1
  Session Max Seconds:        28800
  Type:                       tcp
  Updated Time:               Wed, 15 Feb 2023 13:35:44 UTC
  Version:                    3
```

## Connect to the server

Login to boundary

```shell
boundary authenticate password \
  -auth-method-id ampw_RjuRgvQURS
```

Fetch the credentials

```
export BOUNDARY_TOKEN=$(cat .boundary_token)
```

```shell
boundary targets authorize-session \
  -token env://BOUNDARY_TOKEN \
  -id ttcp_FZ2bhOwmle \
  -format json > .session_token

cat .session_token  | jq -r '.item.credentials[] | select(.credential_source.name == "kubernetes vault admin") | .secret.decoded.service_account_token' > .kube_token
cat .session_token  | jq -r '.item.credentials[] | select(.credential_source.name == "kubernetes vault ca") | .secret.decoded.data.ca' | base64 -d > .kube_ca
```

Connect to kube

```shell
boundary connect kube \
  -token env://BOUNDARY_TOKEN \
  -target-id=ttcp_FZ2bhOwmle \
  -- --token="$(cat .kube_token)" --certificate-authority=".kube_ca" get pods -n vault

```

<div style={{height: "400px"}}/>
