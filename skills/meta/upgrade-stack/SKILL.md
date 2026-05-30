---
name: upgrade-stack
description: "Runs claude-stack-doctor.sh to upgrade bun/npm/cargo globals and re-apply --smol patches. Use when user says \"upgrade my stack\", \"update plugins\", \"upgrade claude-mem\", \"reapply patches\", or \"check for updates\". NOT for Claude Code itself — that's manual."
---

# upgrade-stack — keep the Claude Code stack current

User's box runs a stack with **local patches** that get wiped by plugin upgrades. The tool `~/.local/bin/claude-stack-doctor.sh` automates upgrade + re-patch in one go.

## When to use

- After `/plugin update` inside Claude Code (rebuilds plugin cache → wipes my --smol patches)
- Weekly maintenance (`claude-stack-doctor --check` to see what's outdated)
- When user says "upgrade stack" / "update everything" / "check for updates"
- When a fresh claude-mem version directory appears (e.g. 13.3.0 alongside 13.2.0)

## How to use

```bash
# Diagnose only, no changes:
claude-stack-doctor.sh --check

# Upgrade everything + re-apply patches:
claude-stack-doctor.sh

# Just re-apply patches (fast, idempotent — use after a manual /plugin update):
claude-stack-doctor.sh --patches-only

# Quiet (only failures + actual changes printed):
claude-stack-doctor.sh -q
```

## What it does

1. **bun globals** (`bun upgrade` + `bun update -g`) — picks up new gbrain, rtk if bun-installed, etc.
2. **npm globals** — reports outdated but does NOT auto-upgrade `@anthropic-ai/claude-code` (restart-sensitive).
3. **cargo globals** — if `cargo-install-update` is present, runs `cargo install-update -a`. Otherwise notes how to install it.
4. **RTK** — reports current version; upgrade path varies (brew on mac, cargo/bun on Linux).
5. **claude-mem --smol patches** — finds latest version directory, re-applies the 3-file patch suite if missing. Idempotent — running twice is a no-op.

## What it does NOT do

- **Won't upgrade Claude Code itself.** That kills active sessions. User runs `npm i -g @anthropic-ai/claude-code` manually when ready.
- **Won't run `/plugin update`.** That's an interactive Claude Code command; only the user inside a session can run it.
- **Won't kill running daemons.** New `--smol` settings only apply to *new* claude-mem worker spawns. To force-recycle the daemon: `pkill -f worker-service.cjs` — it respawns on next SessionStart hook.

## After running

If patches were freshly applied, tell user:
> Patches applied. Inside any Claude Code session, the running claude-mem daemon is still on the *old* (non-patched) code. To pick up `--smol`:
> `pkill -f worker-service.cjs` — the next SessionStart hook will respawn it.

If `claude-mem` version directory changed (e.g. 13.3.0 just appeared), confirm patches landed in the new dir:
```bash
grep -l 'BUN_NO_SMOL\|LOCAL PATCH' ~/.claude/plugins/cache/thedotmack/claude-mem/<NEW_VERSION>/scripts/*.{js,cjs}
```

## Failure modes

| Symptom | Cause | Fix |
|---|---|---|
| "CANNOT PATCH (anchor not found)" | Upstream `claude-mem` rewrote the file beyond recognition | Manual review of `~/.claude/plugins/cache/thedotmack/claude-mem/<ver>/scripts/`; consult §7 of `~/Documents/claude-code-setup-prompt.md` for the original patch sites |
| `cargo-install-update missing` | Optional cargo-update tool not installed | `cargo install cargo-update` if user wants cargo globals auto-upgraded |
| `bun update -g` errors | Network or registry issue | Check `bun pm ls -g` for the problem package, upgrade individually |

## Related

- See memory `project-memory-tuning` for the full reasoning behind `--smol`.
- See memory `project-skill-layout` for the broader skill / plugin convention on this machine.
- `/plugin update` inside Claude Code is the interactive companion to this tool — they're complementary.
