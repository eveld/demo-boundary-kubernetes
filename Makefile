.PHONY: token connect

PASSWORD := $(shell terraform -chdir=terraform output -raw erik_password)
AUTH_METHOD := $(shell terraform -chdir=terraform output -raw org_auth_method_id)
LOGIN_NAME := $(shell terraform -chdir=terraform output -raw erik_username)

TARGET_ID := $(shell terraform -chdir=terraform output -raw target_id)

BOUNDARY_TOKEN := $(shell \
	PASSWORD=$(PASSWORD) \
  boundary authenticate password \
    -keyring-type=none \
    -auth-method-id $(AUTH_METHOD) \
    -login-name $(LOGIN_NAME) \
    -format=json \
    -password="env://PASSWORD" \
  | jq -r .item.attributes.token)


token:
	@echo $(BOUNDARY_TOKEN)

connect: 
	$(shell \
		)