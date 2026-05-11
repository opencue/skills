---
name: coolify
description: >-
  Use when user says "Coolify", "deploy backend", or "check deploy logs" and needs Coolify
  deployment guidance. Covers env vars, builds, restarts, logs, health checks, and rollback
  risk.
---

# Coolify CLI Skill

Operate Coolify API workflows from Codex using the local `coolify` CLI.

## Use This Skill For

- Connecting Codex to Coolify Cloud or a self-hosted Coolify instance
- Listing or managing apps, deployments, services, databases, and servers
- Managing app/service environment variables with sync-safe behavior
- Running multi-context workflows (prod/staging/dev)

## Preconditions

- `coolify` binary is installed and available in `PATH`
- Config file exists at `~/.config/coolify/config.json`
- API token comes from `<coolify-url>/security/api-tokens`

## Install / Verify

```bash
coolify version
coolify config
coolify --help
```

Linux/macOS install (recommended upstream):

```bash
curl -fsSL https://raw.githubusercontent.com/coollabsio/coolify-cli/main/scripts/install.sh | bash
```

## Context Setup

Cloud:

```bash
coolify context set-token cloud <token>
```

Self-hosted (set default context immediately):

```bash
coolify context add -d <context_name> <url> <token>
```

Switch default context:

```bash
coolify context use <context_name>
# or
coolify context set-default <context_name>
```

Verify active context:

```bash
coolify context verify
coolify context version
```

## Preferred Execution Patterns

Use JSON for automation or scripted follow-up:

```bash
coolify app list --format=json
coolify deploy list --format=json
coolify server list --format=json
```

Multi-context operations:

```bash
coolify --context=staging app list
coolify --context=prod deploy name api --force
```

## Safe Defaults

- Do **not** pass `-s/--show-sensitive` unless user explicitly asks for secrets.
- Prefer `--format=json` when downstream parsing is needed.
- For destructive commands (`delete`, `remove`, `deploy cancel`), require explicit target IDs and use `--force` only when requested or clearly safe.
- Prefer `env sync --file ...` when bulk-updating variables; this updates existing and creates missing variables without deleting unspecified ones.

## Quick Command Map

```bash
# Context
coolify context list
coolify context get <context_name>

# Apps
coolify app list
coolify app get <uuid>
coolify app logs <uuid>
coolify app env list <uuid>

# Deployments
coolify deploy name <resource_name>
coolify deploy uuid <resource_uuid>
coolify deploy list
coolify deploy get <deployment_uuid>

# Databases and services
coolify database list
coolify service list
coolify server list
```

## Bundled Script

Use the included preflight checker:

```bash
bash <path-to-skill>/scripts/coolify-preflight.sh
```

It validates CLI availability, prints config location, and shows current context state without leaking tokens.
