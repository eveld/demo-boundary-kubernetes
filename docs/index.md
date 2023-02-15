---
sidebar_position: 1
id: index
title: Initialization
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

## Create an Organization and Project Scope

First the organization scope

```shell
boundary scopes create -name 'hashicorp' -scope-id 'global' \
  -recovery-config /boundary/config/boundary_server.hcl \
  -skip-admin-role-creation \
  -skip-default-role-creation
```

```shell
Scope information:
  Created Time:        Wed, 15 Feb 2023 08:16:20 UTC
  ID:                  o_ks6yJYjkui
  Name:                hashicorp
  Updated Time:        Wed, 15 Feb 2023 08:16:20 UTC
  Version:             1
```

We can then create a project that is a child of the organization, to create the child we need the `ID: o_vsQb9UTCNZ` from the previous command.

```
boundary scopes create -name 'myproject' -scope-id o_ks6yJYjkui \
  -recovery-config /boundary/config/boundary_server.hcl \
  -skip-admin-role-creation \
  -skip-default-role-creation
```

```
Scope information:
  Created Time:        Wed, 15 Feb 2023 08:17:43 UTC
  ID:                  p_f0Aa554tqQ
  Name:                myproject
  Updated Time:        Wed, 15 Feb 2023 08:17:43 UTC
  Version:             1

  Scope (parent):
    ID:                o_ks6yJYjkui
    Name:              hashicorp
    Parent Scope ID:   global
    Type:              org
```

## Creating an Auth Method

To log into boundary you need an auth method, we can use a basic username or OIDC, for simplicity, let's use basic username.

```shell
boundary auth-methods create password \
  -recovery-config /boundary/config/boundary_server.hcl \
  -scope-id o_ks6yJYjkui \
  -name 'userpass' \
  -description 'My password auth method'
```

```shell
Auth Method information:
  ID:                     ampw_RjuRgvQURS
    Scope ID:             o_ks6yJYjkui
    Version:              1
    Type:                 password
    Name:                 userpass
    Description:          My password auth method
    Authorized Actions:
      no-op
      read
      update
      delete
      authenticate
```

## Create a Login account

```shell
boundary accounts create password \
  -recovery-config /boundary/config/boundary_server.hcl \
  -login-name "nicj" \
  -auth-method-id ampw_RjuRgvQURS
```

```shell
Account information:
  Auth Method ID:      ampw_RjuRgvQURS
  Created Time:        Wed, 15 Feb 2023 08:23:03 UTC
  ID:                  acctpw_SGyz9zZoWz
  Type:                password
  Updated Time:        Wed, 15 Feb 2023 08:23:03 UTC
  Version:             1
```

## Creating a user

First we create the user and then we associate that user with the login account

```shell
boundary users create \
  -recovery-config /boundary/config/boundary_server.hcl \
  -scope-id o_ks6yJYjkui \
  -name "nicj" \
  -description "Nic Jackson"
```

```
User information:
  Created Time:        Wed, 15 Feb 2023 08:19:19 UTC
  ID:                  u_N26ku3lLHu
  Name:                nicj
  Updated Time:        Wed, 15 Feb 2023 08:19:19 UTC
  Version:             1

  Scope:
    ID:                o_ks6yJYjkui
    Name:              hashicorp
    Parent Scope ID:   global
    Type:              org
```

And associate the accounts

```shell
boundary users add-accounts \
  -recovery-config /boundary/config/boundary_server.hcl \
  -id u_N26ku3lLHu \
  -account acctpw_SGyz9zZoWz
```

```shell
User information:
  Created Time:        Wed, 15 Feb 2023 06:33:51 UTC
  Description:         Nic Jackson
  ID:                  u_UYhuVYiEJ3
  Name:                nicj
  Updated Time:        Wed, 15 Feb 2023 06:39:14 UTC
  Version:             2

  Scope:
    ID:                o_vsQb9UTCNZ
    Name:              hashicorp
    Parent Scope ID:   global
    Type:              org
```

## Creating Roles to Manage Scopes

To administer boundary, the user needs a role, the following roles are similar to the defaults created with boundary.

### Create global anonymous listing role:

```shell
boundary roles create -name 'global_anon_listing' \
  -recovery-config /boundary/config/boundary_server.hcl \
  -scope-id 'global'
```

```shell
Role information:
  Created Time:        Wed, 15 Feb 2023 08:24:35 UTC
  Grant Scope ID:      global
  ID:                  r_RfK3vsAn5h
  Name:                global_anon_listing
  Updated Time:        Wed, 15 Feb 2023 08:24:35 UTC
  Version:             1
```

Add the grants

```shell
boundary roles add-grants \
  -id r_RfK3vsAn5h \
  -recovery-config /boundary/config/boundary_server.hcl \
  -grant 'id=*;type=auth-method;actions=list,authenticate' \
  -grant 'id=*;type=scope;actions=list,no-op' \
  -grant 'id={{.Account.Id}};actions=read,change-password'

boundary roles add-principals \
  -id r_RfK3vsAn5h \
  -recovery-config /boundary/config/boundary_server.hcl \
  -principal 'u_anon'
```

### Create Anonymous listing role for org


```shell
boundary roles create -name 'org_anon_listing' \
  -recovery-config /boundary/config/boundary_server.hcl \
  -scope-id o_ks6yJYjkui
```

```
Role information:
  Created Time:        Wed, 15 Feb 2023 08:26:58 UTC
  Grant Scope ID:      o_ks6yJYjkui
  ID:                  r_4tRyJQU8Wh
  Name:                org_anon_listing
  Updated Time:        Wed, 15 Feb 2023 08:26:58 UTC
  Version:             1
```

Add the grants

```
boundary roles add-grants \
  -id r_4tRyJQU8Wh \
  -recovery-config /boundary/config/boundary_server.hcl \
  -grant 'id=*;type=auth-method;actions=list,authenticate' \
  -grant 'type=scope;actions=list' \
  -grant 'id={{.Account.Id}};actions=read,change-password'

boundary roles add-principals \
  -id r_4tRyJQU8Wh \
  -recovery-config /boundary/config/boundary_server.hcl \
  -principal 'u_anon'
```

### Create Org admin role 

```shell
boundary roles create -name 'org_admin' \
  -recovery-config /boundary/config/boundary_server.hcl \
  -scope-id 'global' \
  -grant-scope-id o_ks6yJYjkui
```

```shell
Role information:
  Created Time:        Wed, 15 Feb 2023 08:28:29 UTC
  Grant Scope ID:      o_ks6yJYjkui
  ID:                  r_8YmTL40tnl
  Name:                org_admin
  Updated Time:        Wed, 15 Feb 2023 08:28:29 UTC
  Version:             1
```

Add the grant

```shell
boundary roles add-grants \
  -id r_8YmTL40tnl \
  -recovery-config /boundary/config/boundary_server.hcl \
  -grant 'id=*;type=*;actions=*'
```

Assign the role to a user

```
boundary roles add-principals \
  -id r_8YmTL40tnl \
  -recovery-config /boundary/config/boundary_server.hcl \
  -principal u_N26ku3lLHu
```

### Create the Project admin

```shell
boundary roles create -name 'project_admin' \
  -recovery-config /boundary/config/boundary_server.hcl \
  -scope-id o_ks6yJYjkui \
  -grant-scope-id p_f0Aa554tqQ
```

```shell
Role information:
  Created Time:        Wed, 15 Feb 2023 08:30:26 UTC
  Grant Scope ID:      p_f0Aa554tqQ
  ID:                  r_9F3vSbDRMu
  Name:                project_admin
  Updated Time:        Wed, 15 Feb 2023 08:30:26 UTC
  Version:             1
```

```shell
boundary roles add-grants \
  -id r_9F3vSbDRMu \
  -recovery-config /boundary/config/boundary_server.hcl \
  -grant 'id=*;type=*;actions=*'
```

```shell
boundary roles add-principals \
  -id r_9F3vSbDRMu \
  -recovery-config /boundary/config/boundary_server.hcl \
  -principal u_N26ku3lLHu

```

## Login as New User

```
boundary authenticate password \
  -auth-method-id ampw_RjuRgvQURS
```

```
Please enter the login name (it will be hidden): 
Please enter the password (it will be hidden): 

Authentication information:
  Account ID:      acctpw_4xDeGHRBdm
  Auth Method ID:  ampw_N2sQbk6mlA
  Expiration Time: Wed, 22 Feb 2023 07:02:43 UTC
  User ID:         u_UYhuVYiEJ3
Error opening "pass" keyring: Specified keyring backend not available
The token was not successfully saved to a system keyring. The token is:

at_a6qEkgrUR4_s15nmtSy85pgEy7hNW599VdNwgszHyW3YXvXGG3NfkRYJAxdz19PtenoPhqWobb7KPk4dBRsY3jsQNvdKz4bfChEKsPzo7qZTxRAN9Kr6XFi8rqgj1XmB4rXT5

It must be manually passed in via the BOUNDARY_TOKEN env var or -token flag. Storing the token can also be disabled via -keyring-type=none.
```

<div style={{height: "400px"}}/>
