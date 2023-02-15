---
sidebar_position: 2
id: ssh
title: Configuring an SSH target
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

## Creating a Target

```shell
boundary targets create tcp \
   -recovery-config /boundary/config/boundary_server.hcl \
   -name="vm" \
   -description="SSH access for virtual machine" \
   -default-port=22 \
   -address=vm.container.shipyard.run \
   -scope-id=p_f0Aa554tqQ
```

```
Target information:
  Address:                    vm.container.shipyard.run
  Created Time:               Wed, 15 Feb 2023 07:14:40 UTC
  Description:                SSH access for virtual machine
  ID:                         ttcp_eNnfgwp1FL
  Name:                       vm
  Session Connection Limit:   -1
  Session Max Seconds:        28800
  Type:                       tcp
  Updated Time:               Wed, 15 Feb 2023 07:14:40 UTC
  Version:                    1
```

## Create Role and add specific permission to the target if not using a project admin

```shell
boundary roles create -name 'vm_session' \
  -recovery-config /boundary/config/boundary_server.hcl \
  -scope-id o_vsQb9UTCNZ \
  -grant-scope-id p_9Gb7bRpQ8H
```

```shell
Role information:
  Created Time:        Wed, 15 Feb 2023 08:03:07 UTC
  Grant Scope ID:      p_9Gb7bRpQ8H
  ID:                  r_p9FXB1xxRG
  Name:                vm_session
  Updated Time:        Wed, 15 Feb 2023 08:03:07 UTC
  Version:             1
```

```shell
boundary roles add-grants \
  -id r_p9FXB1xxRG \
  -recovery-config /boundary/config/boundary_server.hcl \
  -grant 'id=ttcp_eNnfgwp1FL;actions=authorize-session'
```

```
Role information:
  Created Time:        Wed, 15 Feb 2023 06:59:20 UTC
  Grant Scope ID:      o_vsQb9UTCNZ
  ID:                  r_KsZbpt7adX
  Name:                project_admin
  Updated Time:        Wed, 15 Feb 2023 07:00:55 UTC
  Version:             2
```

```shell
boundary roles add-principals \
  -id r_p9FXB1xxRG \
  -recovery-config /boundary/config/boundary_server.hcl \
  -principal <non admin user>
```

## Connecting to the target

```shell
boundary authenticate password \
  -auth-method-id ampw_RjuRgvQURS
```

```shell
boundary connect ssh \
  -token env://BOUNDARY_TOKEN \
  -target-id=ttcp_uDjJL4YnMh -- -l root -i /files/id_rsa
```

<div style={{height: "400px"}}/>
