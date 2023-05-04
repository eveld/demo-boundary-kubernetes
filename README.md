# Talk

- talk about boundary
- what does boundary do?
- how would we traditionally solve this? -> bastion
- challenges with bastion
- how does boundary do this?

- zero trust mindset
- access to daily systems vs exceptions
- what happens in case of an incident?
- challenges with this
- what is rift? -> art of the possible
- how does rift work?

- where can we take it from here?
- hcp boundary
- multi-hop workers
- credential injection
- vault ssh helper
- easily add workers to private networks -> nomad example

## Demo

Create the environment

```shell
LOG_LEVEL=debug shipyard run
```

Start a cloudflare tunnel

```shell
cloudflared tunnel --hostname rift.stickhorse.io --url localhost:4444 --name rift
```

## Accessing targets

Get the boundary details

```shell
export PASSWORD=$(terraform -chdir=terraform output -raw erik_password)
export AUTH_METHOD=$(terraform -chdir=terraform output -raw org_auth_method_id)
export LOGIN_NAME=$(terraform -chdir=terraform output -raw erik_username)
export TARGET_ID=$(terraform -chdir=terraform output -raw target_id)
```

Authenticate with boundary

```shell
export BOUNDARY_TOKEN=$(
  boundary authenticate password \
    -keyring-type=none \
    -auth-method-id ${AUTH_METHOD} \
    -login-name ${LOGIN_NAME} \
    -format=json \
    -password="env://PASSWORD" \
  | jq -r .item.attributes.token
)
```

Execute kubectl commands against the target

```shell
boundary connect kube \
  --token="env://BOUNDARY_TOKEN" \
  --target-id=${TARGET_ID} \
  -- get pods --all-namespaces
```
