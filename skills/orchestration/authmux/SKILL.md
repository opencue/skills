---
name: authmux
description: Use when the user mentions "authmux", "agent-auth", account switching, multi-account management for Codex/Claude/Kiro, rotating between API accounts, account health checks, or parallel Claude Code sessions with different accounts.
---

# authmux

> Multi-account auth multiplexer for AI CLI agents — Claude Code, Codex, Kiro CLI.

Repo: `~/Documents/recodee/authmux/`. Installed globally as `authmux` (also aliased as `agent-auth`).

## What it does

Manages named snapshots of `~/.codex/auth.json` (and Claude/Kiro equivalents). Switch accounts instantly without re-logging in. Per-terminal session memory keeps each shell pinned to its account.

## Quick reference

```bash
# List & status
authmux list                    # show all saved accounts
authmux current                 # active account name
authmux check                   # health of all accounts
authmux status                  # auto-switch + service status
authmux forecast                # health forecast (best-first)

# Switch accounts
authmux switch                  # interactive picker
authmux switch 2                # by row number
authmux switch "email@"         # by email/alias fragment
authmux use <name>              # direct switch by name
authmux auto-switch             # pick healthiest account

# Save & import
authmux save                    # snapshot current auth.json
authmux login                   # codex login + save
authmux import <path>           # import auth file(s)
authmux export <dir>            # export all snapshots

# Kiro CLI accounts
authmux kiro                    # switch Kiro account
authmux kiro-login              # login + save Kiro snapshot

# Parallel Claude Code
authmux parallel list           # list parallel account dirs
authmux parallel setup          # set up CLAUDE_CONFIG_DIR accounts

# Maintenance
authmux clean                   # remove stale backups/symlinks
authmux remove                  # interactive multi-select removal
authmux config                  # manage auto-switch config
authmux savings                 # rotation efficiency stats

# Background service
authmux daemon                  # run auto-switch daemon

# Shell hook (per-terminal pinning)
authmux hook-install            # install shell hook
authmux hook-status             # check hook status
authmux hook-remove             # remove hook

# Diagnostics
authmux diag                    # write redacted diagnostic bundle
authmux update                  # check for updates
```

## Key concepts

- **Snapshots**: Named copies of `auth.json` stored under `~/.codex/accounts/`.
- **Session memory**: Per-terminal (by shell PID) — switching in one terminal doesn't affect others.
- **Auto-switch**: Background daemon rotates to healthiest account when current one degrades.
- **Health**: Accounts are scored by API reachability, token freshness, and rate-limit headroom.
- **Parallel mode**: Multiple Claude Code instances with separate `CLAUDE_CONFIG_DIR` per account.

## Development

```bash
cd ~/Documents/recodee/authmux
npm run build                   # tsc → dist/
npm test                        # build + run tests
```
