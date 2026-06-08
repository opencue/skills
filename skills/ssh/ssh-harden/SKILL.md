---
name: ssh-harden
description: >-
  Use when the user wants to harden an SSH server: enforce key-only auth,
  disable root and password login, add fail2ban, or lock down sshd_config.
  Triggers: "harden ssh", "disable password login", "secure sshd", "fail2ban".
tags: [ssh, security, hardening, sshd, fail2ban]
category: ssh
triggers: ["harden ssh", "disable password login", "secure sshd", "fail2ban", "disable root login", "ssh server hardening"]
allowed-tools: Bash(ssh:*), Bash(sshd:*), Bash(systemctl:*), Bash(fail2ban-client:*), Read, Edit
---

# SSH harden

Lock down an SSH server so it accepts keys only, refuses root and password
logins, and bans brute-force IPs. The order matters: prove key access first,
then disable passwords. Skipping that order is how people lock themselves out
of a remote box they can no longer reach.

## When to activate

- The user wants to secure a new server's SSH before it faces the internet.
- The user asks to "disable password login", "turn off root SSH", "harden sshd", or "add fail2ban".
- A security review flags password auth or root login as open.

## Steps

### 1. Prove key auth works FIRST (anti-lockout)

Before changing anything, confirm you can log in with a key (see the `ssh-keys` skill):

```bash
ssh -i ~/.ssh/id_ed25519_prod user@host 'echo key-auth-ok'
```

Keep a SECOND ssh session open to the host for the whole process. If a change breaks login, you fix it from the open session instead of being locked out.

### 2. Edit sshd_config

Edit `/etc/ssh/sshd_config` (or drop a file in `/etc/ssh/sshd_config.d/`):

```
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
PermitEmptyPasswords no
# Optional: restrict who may log in
# AllowUsers deploy
# Optional: drop idle sessions after ~15 min
ClientAliveInterval 300
ClientAliveCountMax 3
```

### 3. Validate, then reload (never restart blind)

```bash
sudo sshd -t && echo "config OK"        # syntax check; do NOT reload if this fails
sudo systemctl reload ssh               # or `reload sshd` on some distros
```

`reload` keeps existing sessions alive. Test a NEW login from a separate terminal before closing your open session.

### 4. Add fail2ban (ban brute-force IPs)

```bash
sudo apt install -y fail2ban
sudo tee /etc/fail2ban/jail.d/sshd.local >/dev/null <<'EOF'
[sshd]
enabled = true
maxretry = 4
bantime = 1h
findtime = 10m
EOF
sudo systemctl enable --now fail2ban
sudo fail2ban-client status sshd
```

### 5. Verify the lockdown

```bash
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no user@host   # must be REFUSED
ssh root@host                                                                   # must be REFUSED
ssh user@host 'echo still-in'                                                    # key login still works
```

## Prerequisites

- `ssh`, `sshd` (OpenSSH server on the host). apt: `sudo apt install -y openssh-server`.
- `fail2ban` for brute-force banning. apt: `sudo apt install -y fail2ban`.
- A working key login for your user BEFORE you start (see the `ssh-keys` skill).

## Example

> User: "New VPS is up. Turn off password and root login and add fail2ban, but don't lock me out."

1. Confirm `ssh -i ~/.ssh/id_ed25519 deploy@vps 'echo ok'` works; open a second session and keep it.
2. Set `PermitRootLogin no` + `PasswordAuthentication no` + `KbdInteractiveAuthentication no` in `sshd_config.d/`.
3. `sudo sshd -t` passes, then `sudo systemctl reload ssh`; open a NEW session to confirm.
4. Install fail2ban with the `[sshd]` jail; check `fail2ban-client status sshd`.

## Rules

- Confirm key login works and keep a second session open BEFORE disabling password auth. This is the one rule that prevents lockouts.
- Run `sudo sshd -t` before every reload. A bad config plus a restart can kill the daemon and your access.
- Use `reload`, not `restart`, so live sessions survive the change.
- `PasswordAuthentication no` only takes effect if no other included config re-enables it; check `/etc/ssh/sshd_config.d/` for overrides with `sudo sshd -T | grep -i passwordauth`.
- A non-default port reduces log noise but is not security on its own. Keys plus fail2ban are what matter.
