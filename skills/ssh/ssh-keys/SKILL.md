---
name: ssh-keys
description: >-
  Use when the user wants to generate an SSH key (ed25519), copy a public key to
  a server with ssh-copy-id, load keys into ssh-agent, or set up passwordless /
  per-host key auth. Triggers: "ssh key", "ssh-keygen", "passwordless ssh".
tags: [ssh, keys, ssh-agent, authentication]
category: ssh
triggers: ["ssh key", "ssh-keygen", "passwordless ssh", "ssh-copy-id", "add key to agent", "generate ssh key"]
allowed-tools: Bash(ssh-keygen:*), Bash(ssh-copy-id:*), Bash(ssh-add:*), Bash(ssh:*)
---

# SSH keys

Key auth replaces passwords with a keypair: a private key stays on your machine,
the public key goes on the server. This skill generates a modern key, installs it
on a host, and loads it into the agent so you type the passphrase once.

## When to activate

- The user has no key yet, or wants a fresh per-host key.
- The user wants to log in without typing a password each time.
- The user asks to "set up an ssh key", "copy my key to the server", or "add my key to the agent".

## Steps

### Generate a key (ed25519)

```bash
ssh-keygen -t ed25519 -C "you@host-or-purpose" -f ~/.ssh/id_ed25519_prod
```

ed25519 is the current default: short, fast, well supported. Set a passphrase when asked (the agent unlocks it once per session). Use a distinct `-f` name per purpose so one leaked key has a small blast radius.

### Copy the public key to a server

```bash
ssh-copy-id -i ~/.ssh/id_ed25519_prod.pub user@host
```

This appends the PUBLIC key to the host's `~/.ssh/authorized_keys` with correct permissions. If `ssh-copy-id` is missing, do it by hand:

```bash
cat ~/.ssh/id_ed25519_prod.pub | ssh user@host 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'
```

### Load the key into ssh-agent

```bash
eval "$(ssh-agent -s)"          # start the agent if needed
ssh-add ~/.ssh/id_ed25519_prod  # type the passphrase once
ssh-add -l                      # list loaded keys
```

On macOS, persist to the keychain: `ssh-add --apple-use-keychain ~/.ssh/id_ed25519_prod`.

### Verify

```bash
ssh -i ~/.ssh/id_ed25519_prod user@host 'echo key-auth-ok'
```

## Prerequisites

- `ssh-keygen`, `ssh-add` (OpenSSH client). apt: `sudo apt install -y openssh-client`.
- `ssh-copy-id` (usually bundled with OpenSSH; the manual fallback above needs none).

## Example

> User: "Set me up to push to the new build server without a password."

1. `ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_build -C build`.
2. `ssh-copy-id -i ~/.ssh/id_ed25519_build.pub deploy@build.example.com`.
3. `ssh-add ~/.ssh/id_ed25519_build`, then test with `ssh -i ~/.ssh/id_ed25519_build deploy@build.example.com 'hostname'`.
4. Pair with the `ssh-config` skill so `IdentityFile` points at the new key.

## Rules

- NEVER copy or paste the private key (`id_ed25519_prod`, no `.pub`). Only the `.pub` file goes on servers.
- The private key must be mode 600; `ssh-keygen` sets this, do not loosen it.
- One key per purpose or per machine beats one key everywhere; revoking is then a single `authorized_keys` line.
- A passphrase plus the agent gives password-free use without an unprotected key on disk.
