---
name: ssh-config
description: >-
  Use when the user wants to set up or edit ~/.ssh/config, add a Host alias,
  configure a ProxyJump/bastion hop, or speed up repeat connections with
  ControlMaster multiplexing. Triggers: "ssh config", "host alias", "jump host".
tags: [ssh, config, proxyjump, multiplexing]
category: ssh
triggers: ["ssh config", "host alias", "jump host", "proxyjump", "ssh multiplexing", "~/.ssh/config"]
allowed-tools: Bash(ssh:*), Read, Edit, Write
---

# SSH config

`~/.ssh/config` turns `ssh -i ~/.keys/prod -p 2222 deploy@10.0.0.5` into `ssh prod`.
It also holds the settings that make connections faster and reach hosts behind a
bastion. This skill writes correct `Host` blocks and the options worth knowing.

## When to activate

- The user wants a short alias for a host they reach often.
- The user reaches a private host through a jump/bastion box (ProxyJump).
- Repeat connections to the same host are slow and could share one connection (ControlMaster).
- The user asks to "set up ssh config", "add a host", or "configure a jump host".

## Steps

### Add a host alias

Append a block to `~/.ssh/config` (create the file with mode 600 if missing):

```
Host prod
    HostName 10.0.0.5
    User deploy
    Port 2222
    IdentityFile ~/.ssh/id_ed25519_prod
    IdentitiesOnly yes
```

Now `ssh prod` works. `IdentitiesOnly yes` stops the agent from offering every key (which can trip `MaxAuthTries`).

### Reach a private host through a bastion (ProxyJump)

```
Host bastion
    HostName bastion.example.com
    User jump

Host app-internal
    HostName 10.0.1.20
    User app
    ProxyJump bastion
```

`ssh app-internal` hops through `bastion` in one command. Chain hops with `ProxyJump a,b,c`.

### Speed up repeat connections (multiplexing)

```
Host *
    ControlMaster auto
    ControlPath ~/.ssh/cm-%r@%h:%p
    ControlPersist 10m
```

The first connection opens a master socket; later `ssh`/`scp`/`rsync` to the same host reuse it, skipping the handshake. Drop a stuck master with `ssh -O exit prod`.

### Keep-alives for flaky links

```
Host *
    ServerAliveInterval 30
    ServerAliveCountMax 3
```

## Prerequisites

- `ssh` (OpenSSH client). apt: `sudo apt install -y openssh-client` · brew: preinstalled.

## Example

> User: "I keep typing `ssh -p 2222 deploy@10.0.0.5 -i ~/.ssh/deploy`. Make it `ssh prod` and reuse the connection."

1. Append a `Host prod` block with HostName/User/Port/IdentityFile.
2. Add a `Host *` block with ControlMaster/ControlPath/ControlPersist.
3. Verify: `ssh -G prod | grep -E 'hostname|user|port'` prints the resolved settings, then `ssh prod`.

## Rules

- `~/.ssh/config` must be mode 600 and `~/.ssh` mode 700, or OpenSSH ignores them.
- More specific `Host` blocks go ABOVE `Host *`; the first matching value for each key wins.
- Test resolution without connecting using `ssh -G <alias>`; it prints the effective config.
- Put per-host keys with `IdentityFile` + `IdentitiesOnly yes` so the right key is offered first.
