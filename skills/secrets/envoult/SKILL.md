---
name: envoult
description: 'Use when user says "envoult", "manage my secrets", "push env vars to coolify", "diff secrets against coolify", "rotate a secret", "open the vault". Manages env vars and secrets across multiple Coolify-deployed apps via an age-encrypted vault — set/get/list keys, reconcile local secrets with coolify app env, and sync drift. Use when pasting STRIPE_API_KEY / RESEND_API_KEY / BILLINGO_API_KEY into local .env files feels wrong, or when the user mentions "envoultd" or the encrypted secret vault.'
---

# envoult

> **env**ironment secrets, encrypted in a v**ault**.

`envoult` replaces the loose pattern of `.env.coolify` mirror files with one age-encrypted store + one CLI + one MCP daemon. Repo lives at `~/Documents/envoult/`. Design spec at `~/Documents/envoult/docs/design.md`.

## Core principle

All shop secrets (Stripe, Resend, Billingo, DB credentials, webhook signing keys, …) live in a single `~/.config/envoult/vault.age` file, encrypted with the user's master passphrase. Two-level namespace: `profile → env → KEY` (e.g., `marva/prod/STRIPE_API_KEY`). Push to Coolify with one command; diff against Coolify when in doubt.

## Quick reference

```bash
# Bootstrap (one-time)
envoult init                                   # creates the vault
envoult unlock                                 # cache passphrase for 1h (--ttl 30m to shorten)
envoult lock                                   # purge cache

# Read
envoult list                                   # all profiles
envoult list marva                             # envs in marva
envoult list marva prod                        # keys (values masked)
envoult list marva prod --values               # show values (confirms first)
envoult get marva prod STRIPE_API_KEY          # raw value to stdout

# Write
envoult set marva prod STRIPE_API_KEY sk_live_…    # inline
envoult set marva prod LARGE_MULTILINE              # opens $EDITOR
envoult delete marva prod OLD_KEY --yes
envoult import marva prod --file /path/to/.env     # bulk upsert

# Sync to/from Coolify
envoult diff coolify marva prod gy03fgoo6d9filocrlxyued8   # show drift
envoult sync coolify marva prod <app_uuid>                  # vault → Coolify (with confirm)
envoult pull coolify marva prod <app_uuid>                  # Coolify → vault (with confirm)

# MCP daemon (for me to use)
envoult mcp                                                  # shells to envoultd over stdio
```

## When to use envoult

- Setting up a new Coolify app's env vars: `envoult import` the existing `.env`, then `envoult sync coolify`.
- Auditing drift: `envoult diff coolify <profile> <env> <app_uuid>` shows add/change/remove keys, masked by default; add `--reveal` to see values.
- Rotating a secret: `envoult set <profile> <env> <KEY> <new>`, then `envoult sync coolify …`.
- Reading a secret without leaking it to history: `envoult get … | clip` (or pipe straight to the consumer).

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
| `envoult_get` | read one value; values masked unless `reveal: true` is set in the call |
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
envoult import marva prod --file ~/Documents/medusa-shops/szaloniroda/marva/apps/backend/.env.coolify
envoult diff coolify marva prod gy03fgoo6d9filocrlxyued8   # sanity check
shred -u ~/Documents/medusa-shops/szaloniroda/marva/apps/backend/.env.coolify   # only after diff is clean
```

### Pre-sync sanity check (use the MCP from Claude)

Ask Claude to call `envoult_plan_sync` — it returns the add/change/remove breakdown without touching Coolify. Approve the plan, then run `envoult sync coolify …` in your terminal.

## Status

v0.1 scaffold landed 2026-05-20 — workspace builds, all crates have tests, no Coolify endpoint wired against a live API yet (HTTP client tests use `wiremock`). First real-world rollout: migrate marva's `.env.coolify` into the vault.
