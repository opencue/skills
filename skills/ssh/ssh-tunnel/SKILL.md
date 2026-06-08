---
name: ssh-tunnel
description: >-
  Use when the user wants SSH port forwarding: a local tunnel (-L) to reach a
  remote service, a reverse tunnel (-R) to expose a local one, or a dynamic
  SOCKS proxy (-D). Triggers: "ssh tunnel", "forward a port", "reverse tunnel".
tags: [ssh, tunnel, port-forwarding, socks]
category: ssh
triggers: ["ssh tunnel", "forward a port", "reverse tunnel", "socks proxy", "port forward over ssh", "ssh -L", "ssh -R"]
allowed-tools: Bash(ssh:*), Bash(autossh:*)
---

# SSH tunnel

SSH can forward TCP ports across the encrypted connection. Three directions cover
almost every case: pull a remote service to your machine (`-L`), push a local
service to the remote (`-R`), or send all traffic through the host as a proxy
(`-D`). This skill picks the right flag and keeps the tunnel alive.

## When to activate

- The user wants to reach a remote-only service (a database, an admin UI) from their laptop.
- The user wants a remote host to reach a service running on their laptop (the paste-image daemon, a local API).
- The user wants to browse through a remote host as a SOCKS proxy.
- The user says "tunnel a port", "port forward over ssh", or "reverse tunnel".

## Steps

### Local forward (-L): reach a remote service locally

```bash
ssh -L 5432:localhost:5432 user@dbhost
```

Now `localhost:5432` on your machine reaches the database bound to `localhost:5432` on `dbhost`. The pattern is `-L <local_port>:<target_host>:<target_port>`, where the target is resolved FROM the remote side.

### Reverse forward (-R): expose a local service on the remote

```bash
ssh -R 9998:localhost:9998 user@server
```

Now `localhost:9998` on `server` reaches port 9998 on your machine. This is exactly what the `ssh-paste-image` skill needs. To let other remote hosts (not just localhost) use it, set `GatewayPorts yes` in the server's sshd config.

### Dynamic proxy (-D): SOCKS through the host

```bash
ssh -D 1080 user@host
```

Point a browser or tool at SOCKS5 `localhost:1080` to route its traffic through `host`.

### Run a tunnel with no shell, in the background

```bash
ssh -fN -L 5432:localhost:5432 user@dbhost
```

`-N` means no remote command, `-f` backgrounds after auth. Find and stop it with `pgrep -af 'ssh -fN'` then `kill <pid>`.

### Make it permanent in ~/.ssh/config

```
Host dbhost
    HostName db.example.com
    User app
    LocalForward 5432 localhost:5432
```

### Auto-reconnecting tunnel

```bash
autossh -M 0 -fN -L 5432:localhost:5432 user@dbhost
```

`autossh` restarts the tunnel if it drops. Pair with `ServerAliveInterval` from the `ssh-config` skill.

## Prerequisites

- `ssh` (OpenSSH client). apt: `sudo apt install -y openssh-client`.
- `autossh` for auto-reconnect (optional). apt: `sudo apt install -y autossh` · brew: `brew install autossh`.

## Example

> User: "I need to hit the staging Postgres on the bastion from my laptop with psql."

1. `ssh -fN -L 5432:localhost:5432 user@bastion`.
2. `psql -h localhost -p 5432 -U app staging` connects through the tunnel.
3. To make it stick, add a `LocalForward 5432 localhost:5432` line to the `Host bastion` block.

## Rules

- `-L` resolves the target from the REMOTE side; `-R` resolves it from YOUR side. Mixing these two up is the usual reason a tunnel "does nothing".
- Reverse forwards reach only `localhost` on the server unless `GatewayPorts yes` is set in sshd.
- A privileged local port (<1024) needs root; pick a high port instead.
- Background tunnels (`-fN`) are easy to forget. Track them with `pgrep -af ssh` and stop them when done.
