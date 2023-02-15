#! /bin/sh

scope_id=$(boundary scopes create -name 'hashicorp' -scope-id 'global' \
  -recovery-config ./config/boundary_server.hcl \
  -skip-admin-role-creation \
  -skip-default-role-creation \
  -format=json | jq -r .item.id)

project_id=$(boundary scopes create -name 'myproject' -scope-id ${scope_id} \
  -recovery-config ./config/boundary_server.hcl \
  -skip-admin-role-creation \
  -skip-default-role-creation \
  -format=json | jq -r .item.id)

auth_method_id=$(boundary auth-methods create password \
  -recovery-config ./config/boundary_server.hcl \
  -scope-id ${scope_id} \
  -name 'userpass' \
  -description 'My password auth method' \
  -format=json | jq -r .item.id)

login_id=$(PASSWORD=password boundary accounts create password \
  -recovery-config ./config/boundary_server.hcl \
  -login-name "nicj" \
  -auth-method-id ${auth_method_id} \
  -password="env://PASSWORD" \
  -format=json | jq -r .item.id)

user_id=$(boundary users create \
  -recovery-config ./config/boundary_server.hcl \
  -scope-id ${scope_id} \
  -name "nicj" \
  -description "Nic Jackson" \
  -format=json | jq -r .item.id)

boundary users add-accounts \
  -recovery-config ./config/boundary_server.hcl \
  -id ${user_id} \
  -account ${login_id}

anon_listing_role=$(boundary roles create -name 'global_anon_listing' \
  -recovery-config ./config/boundary_server.hcl \
  -scope-id 'global'  \
  -format=json | jq -r .item.id)

boundary roles add-grants \
  -id ${anon_listing_role} \
  -recovery-config ./config/boundary_server.hcl \
  -grant 'id=*;type=auth-method;actions=list,authenticate' \
  -grant 'id=*;type=scope;actions=list,no-op' \
  -grant 'id={{.Account.Id}};actions=read,change-password'

boundary roles add-principals \
  -id ${anon_listing_role} \
  -recovery-config ./config/boundary_server.hcl \
  -recovery-config /boundary/config/boundary_server.hcl \
  -principal 'u_anon'

org_listing_role=$(boundary roles create -name 'org_anon_listing' \
  -recovery-config ./config/boundary_server.hcl \
  -scope-id ${scope_id} \
  -format=json | jq -r .item.id)

boundary roles add-grants \
  -id ${org_listing_role} \
  -recovery-config ./config/boundary_server.hcl \
  -grant 'id=*;type=auth-method;actions=list,authenticate' \
  -grant 'type=scope;actions=list' \
  -grant 'id={{.Account.Id}};actions=read,change-password'

boundary roles add-principals \
  -id ${org_listing_role} \
  -recovery-config ./config/boundary_server.hcl \
  -principal 'u_anon'

org_admin_role=$(boundary roles create -name 'org_admin' \
  -recovery-config ./config/boundary_server.hcl \
  -scope-id 'global' \
  -grant-scope-id ${scope_id} \
  -format=json | jq -r .item.id)

boundary roles add-grants \
  -id ${org_admin_role} \
  -recovery-config ./config/boundary_server.hcl \
  -grant 'id=*;type=*;actions=*'

boundary roles add-principals \
  -id ${org_admin_role} \
  -recovery-config ./config/boundary_server.hcl \
  -principal ${user_id}

project_admin_role=$(boundary roles create -name 'project_admin' \
  -recovery-config ./config/boundary_server.hcl \
  -scope-id ${scope_id} \
  -grant-scope-id ${project_id} \
  -format=json | jq -r .item.id)

boundary roles add-grants \
  -id ${project_admin_role} \
  -recovery-config ./config/boundary_server.hcl \
  -grant 'id=*;type=*;actions=*'

boundary roles add-principals \
  -id ${project_admin_role} \
  -recovery-config ./config/boundary_server.hcl \
  -principal ${user_id}