---
name: medusa-local-dev
description: Use when user says "start medusa", "medusa local dev", "EADDRINUSE :::9000", "port collision", or "run multiple shops". Coordinates backend + storefront startup across many Medusa shops with stable per-shop ports from ~/Documents/medusa-shops/.dev-ports.yaml.
---

# Running multiple Medusa shops locally

## Core principle

Every shop has **stable, assigned ports** in `~/Documents/medusa-shops/.dev-ports.yaml`. The `medusa-dev` helper (`~/Documents/soul/bin/medusa-dev`) reads that file, starts backend + storefront with the right `PORT=` env, and refuses to start if a port is already held. No more guessing why `pnpm dev` failed — the script tells you which other shop is on the port.

## Quick reference

```bash
medusa-dev list                       # who is up, who is down, on which ports
medusa-dev start marva                # backend (9001) + storefront (3001)
medusa-dev start lifted back          # just the backend
medusa-dev stop  marva                # both
medusa-dev tail  marva back           # follow the backend log
medusa-dev cors-fix marva             # one-time: loosen STORE_CORS/AUTH_CORS to a localhost regex
```

Logs land in `~/.cache/medusa-dev/<shop>.<back|front>.log`. Pidfiles in the same dir.

## Port table

The registry maps shop → backend (90xx) and storefront (30xx). See `~/Documents/medusa-shops/.dev-ports.yaml` for the canonical list. Adding a shop is just an entry — no code change.

| Shop | Backend | Storefront |
|---|---|---|
| recodee | 9000 | 3000 |
| marva | 9001 | 3001 |
| lifted | 9002 | 3002 |
| teherguminet | 9003 | 3003 |
| compastor | 9004 | 3004 |
| munchi-v3 | 9005 | 3005 |
| modulix | 9006 | 3006 |
| base-template | 9008 | 3008 |
| koronakert | 9009 | 3009 |
| 2026/KORONAKERTv2 | 9010 | 3010 |
| 2026/KRSITOFWEBSHOP | 9011 | 3011 |
| 2026/MUNCHI | 9012 | 3012 |
| 2026/WEBUv2 | 9013 | 3013 |

## CORS — set it once per shop

Each backend's `.env` ships with `STORE_CORS=http://localhost:3000,…` which breaks the moment that shop moves off 3000. Fix it once per shop:

```bash
medusa-dev cors-fix marva
```

This rewrites `STORE_CORS`, `AUTH_CORS`, `ADMIN_CORS` in `apps/backend/.env` to a regex Medusa understands:

```
STORE_CORS=^http://localhost:\d+$
AUTH_CORS=^http://localhost:\d+$
ADMIN_CORS=^http://localhost:\d+$
```

The original file is backed up to `<file>.bak.<ts>`. Production `.env` (on Coolify) is untouched.

## Discovery commands

```bash
# Which ports in the 9xxx and 3xxx ranges are held — and by what process?
ss -lntpH 'sport >= :9000 and sport < :9100'
ss -lntpH 'sport >= :3000 and sport < :3100'

# All Medusa node processes
ps -ef | grep -E "node.*medusa|next dev" | grep -v grep
```

## Common situations

| Symptom | What to do |
|---|---|
| `EADDRINUSE :::9000` | `medusa-dev list` → see who owns 9000 → either `medusa-dev stop <that-shop>` or start the new shop (it has its own port). |
| Storefront shows CORS error after starting on `:3001` | Run `medusa-dev cors-fix <shop>` once. |
| `medusa-dev start` says "Port X already in use by 'next'" | A storefront dev is running outside the helper. Find with `ss -lntpH 'sport = :PORT'`, kill it, or stop via its own process. |
| Need a new shop | Add an entry in `.dev-ports.yaml` with the next free index. No script edits. |
| Lost track of what's running | `medusa-dev list` shows live state by port + pidfile. |

## Architecture notes

- The helper checks both `pidfile alive` and `port held` independently. If a previous run died without cleanup, the port can be "busy" without a pidfile — that's a real collision and the script refuses to start.
- Each `start` invocation backgrounds `pnpm --filter backend dev` (or `--filter storefront dev`) with `PORT=<n>`. It does **not** swap `.env`. If your `.env` hardcodes a port, the env wins — remove that line and let the env var drive it.
- Recodee lives at `~/Documents/recodee/`, outside `medusa-shops/`. It's still in the registry; the helper resolves paths against `~/Documents/`.

## When NOT to use this

- Production deploys — those go through Coolify, see the `coolify` skill.
- Building admin frontend (`medusa build`) — not a dev server; use the project's own `pnpm build`.
- Running tests — use the shop's `pnpm test:integration:*` scripts directly.

## Bootstrapping on a fresh machine

1. Ensure `~/Documents/soul/bin/` is on `PATH` (add to `~/.bashrc` or `~/.zshrc`: `export PATH="$HOME/Documents/soul/bin:$PATH"`).
2. Confirm `python3` is available (used by the helper for YAML parsing — no PyYAML dep).
3. `medusa-dev list` — should print the table. If the registry file is missing, the script errors out with a clear message.
