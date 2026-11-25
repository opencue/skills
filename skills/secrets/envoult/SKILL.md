---
name: envoult
description: >-
  Use for envoult or envoultd, managing environment secrets in an age-encrypted
  vault, rotating a secret, or comparing masked vault metadata with a Coolify app.
---

# envoult

> **env**ironment secrets, encrypted in a v**ault**.

`envoult` replaces the loose pattern of `.env.coolify` mirror files with one age-encrypted store + one CLI + one MCP daemon. Repo lives at `~/Documents/envoult/`. Design spec at `~/Documents/envoult/docs/design.md`.

## Core principle

Secrets live in `~/.config/envoult/vault.age`, encrypted with the user's master passphrase. Use the `profile → env → KEY` namespace (for example, `demo/staging/SERVICE_API_KEY`). Agents keep previews masked, never read plaintext values or passphrases, and leave vault writes and deployment syncs to the operator.

## Quick reference

```bash
# Bootstrap (one-time)
envoult init                                   # creates the vault
envoult unlock                                 # cache passphrase for 1h (--ttl 30m to shorten)
envoult lock                                   # purge cache

# Read
envoult list                                   # all profiles
envoult list demo                              # envs in demo
envoult list demo staging                        # keys (values masked)

# Write
envoult set demo staging LARGE_MULTILINE              # opens $EDITOR
envoult import demo staging --file /path/to/.env     # bulk upsert

# Sync to/from Coolify
envoult diff coolify demo staging <app_uuid>   # show drift
envoult sync coolify demo staging <app_uuid>                  # vault → Coolify (with confirm)
envoult pull coolify demo staging <app_uuid>                  # Coolify → vault (with confirm)

# MCP daemon (for me to use)
envoult mcp                                                  # shells to envoultd over stdio
```

## When to use envoult

- Setting up a new Coolify app's env vars: `envoult import` the existing `.env`, then `envoult sync coolify`.
- Auditing drift: `envoult diff coolify <profile> <env> <app_uuid>` shows add/change/remove keys. Keep values masked.
- Rotating a secret: the operator enters the new value in the editor, checks the sync plan, then runs the sync.

## When NOT to use envoult

- One-off `.env.example` placeholders — those are templates, not secrets.
- Anything you actively want in source control — envoult is *not* a config-as-code tool.
- Production-only orchestration — Coolify is still the runtime config source; envoult is the human-facing source of truth that pushes into it.

## MCP integration (read-only by design)

When `envoult mcp` is running (or registered as an MCP server in `~/.claude.json`), Claude can call these tools — all read-only, no writes:

| Tool | Use |
|---|---|
| `envoult_list_profiles` | discover what's in the vault |
| `envoult_list_envs` | discover envs in a profile |
| `envoult_list_keys` | discover keys (no values) |
| `envoult_get` | check one key with the value masked; do not enable reveal |
| `envoult_diff_coolify` | compute drift between vault and a Coolify app |
| `envoult_plan_sync` | dry-run what `sync coolify` would change |
| `envoult_coolify_apps` | list Coolify apps the token reaches |

Writes (`set`, `sync`, `delete`, `pull`) are deliberately **not** exposed via MCP. Claude can recommend changes; the human runs the CLI to apply them.

## Repo layout

```
~/Documents/envoult/
├── Cargo.toml                          # workspace
├── README.md                           # public-facing intro
├── LICENSE                             # MIT
├── docs/design.md                      # full spec
└── crates/
    ├── envoult-core/                   # vault + age crypto + paths
    ├── envoult-coolify/                # Coolify HTTP client
    ├── envoult-cli/   → envoult        # human CLI
    └── envoult-mcp/   → envoultd       # MCP daemon
```

Binaries land in `~/Documents/envoult/target/release/{envoult,envoultd}`. Add that to PATH or symlink to `~/Documents/soul/bin/` (which is already on PATH per the `medusa-local-dev` skill setup).

## Building

```bash
cd ~/Documents/envoult
cargo build --release            # ~3min cold, <30s warm
cargo test --workspace           # 59 tests, all green at last check
```

## Operational notes

- **Vault location**: `~/.config/envoult/vault.age` (age-encrypted; binary mode).
- **Session cache**: `~/.cache/envoult/session.key` (mode 0600, TTL-stamped). The MCP daemon reads this — without `envoult unlock` first, `envoultd` exits with code 2 and stderr `vault is locked. Run \`envoult unlock\` first.`
- **Coolify token**: reused from `~/.config/coolify/config.json` (same token your `coolify` CLI uses). Override via `COOLIFY_URL` + `COOLIFY_TOKEN` env vars.
- **Atomic writes**: every vault save goes through tempfile + rename, so a crash mid-write can't corrupt the vault.
- **Threat model**: see `docs/design.md` § "Security threat model". TL;DR: vault-stolen → offline brute force on the passphrase; session-cache-stolen → bounded by TTL.

## Common operations

### First-time setup on a new machine

```bash
cd ~/Documents/envoult && cargo build --release
ln -s "$(pwd)/target/release/envoult"  ~/Documents/soul/bin/envoult
ln -s "$(pwd)/target/release/envoultd" ~/Documents/soul/bin/envoultd
envoult init                       # prompt for new passphrase
envoult unlock                     # cache for 1h
```

### Migrate an existing `.env.coolify` into envoult

```bash
envoult import demo staging --file /path/to/.env.coolify
envoult diff coolify demo staging <app_uuid>   # sanity check
```

### Pre-sync sanity check (use the MCP from Claude)

Ask Claude to call `envoult_plan_sync` — it returns the add/change/remove breakdown without touching Coolify. Approve the plan, then run `envoult sync coolify …` in your terminal.
