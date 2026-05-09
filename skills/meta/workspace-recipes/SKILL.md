---
name: workspace-recipes
description: >-
  Recipes in ~/Documents/Justfile — workspace-specific commands the user
  has codified. Use when user says "spawn a new shop", "new medusa shop",
  "create shop NAME", "clean disk", "wipe node_modules", "free disk space",
  "show disk usage", "list agents.md", "agent tree", "rebuild colony cli",
  "fix the stop hook". For generic `just` syntax/discovery use the `just`
  skill instead.
---

# workspace-recipes — `~/Documents/Justfile`

Workspace-level recipes the user maintains in `~/Documents/Justfile`. Run any of these from anywhere via `cd ~/Documents && just <recipe>`. The Justfile uses absolute paths internally so `cwd` doesn't matter.

For the underlying `just` tool itself (discovery flags, syntax), see the `just` skill.

## Recipes

### Medusa shops

| Command | What it does |
|---------|--------------|
| `just new-shop NAME` | Spawn a new Medusa shop from `medusa-shops/base-template/` — copies dir, `git init`, copies `.env.example` → `.env` for backend + storefront, runs `pnpm install`. After: edit the two `.env` files, then `just shop-backend NAME`. |
| `just shop-backend SHOP` | `pnpm --filter backend dev` in the shop |
| `just shop-storefront SHOP` | `pnpm --filter storefront dev` in the shop |
| `just shop-build-storefront SHOP` | `pnpm hostinger:build && pnpm hostinger:finalize:static` — produces `dist/client/` ready to upload to `<shop>.hu` Hostinger document root |

### Disk / cleanup

| Command | What it does |
|---------|--------------|
| `just clean` | Wipes ALL `node_modules`, `.next`, `dist`, `build`, `target`, `.turbo`, `.venv` across the workspace. Reports before/after `df`. Run `pnpm install` (or equivalent) per project to restore. **Recovered 35 GB the first time.** |
| `just clean-dry` | Same find, no delete — shows what would go |
| `just disk` | Top 20 largest dirs (depth 3) |
| `just df` | Free / used space on `/home` |

### Docs / soul

| Command | What it does |
|---------|--------------|
| `just agent-tree` | All `AGENTS.md` / `CLAUDE.md` across the workspace |
| `just skills` | List skill categories under `soul/skills/skills/` |
| `just mcps` | List MCP servers under `soul/mcps/mcps/` |

### Recovery

| Command | What it does |
|---------|--------------|
| `just colony-rebuild` | `pnpm install && pnpm --filter @imdeadpool/colony-cli build` in `recodee/colony/`. Run this if the colony Stop/SessionStart hooks start failing with `Cannot find module '/home/deadpool/Documents/recodee/colony/apps/cli/dist/index.js'` — usually after `just clean` wipes `dist/`. |

## When to invoke

- User asks to "spawn / create / start a new (medusa) shop" → `just new-shop NAME`
- User asks to "clean / free disk space / wipe node_modules" → `just clean-dry` first to confirm scale, then `just clean`
- User asks to "show disk usage" → `just disk` then `just df`
- User asks to "list / find AGENTS.md" → `just agent-tree`
- User asks to "fix colony hook" or sees the colony Cannot-find-module error → `just colony-rebuild`

## Reading the Justfile

Always check `~/Documents/Justfile` for the canonical, current recipe list — recipes get added over time. `just --list --unsorted` from any directory inside `~/Documents/` shows the menu.

## Caveats

- Recipes assume cwd is somewhere under `~/Documents/`; they `cd` to absolute paths internally so safe to invoke from anywhere.
- `just clean` is destructive but reversible — the categories it wipes are listed in `~/Documents/.gitignore` and are all rebuildable from source.
- `just new-shop` requires `pnpm` installed and assumes the `base-template/` is up to date.
