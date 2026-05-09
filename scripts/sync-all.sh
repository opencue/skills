#!/usr/bin/env bash
# Orchestrate sync of skills + mcps repos to GitHub.
#
# Cadence approved by user 2026-05-09: Stop hook (per-turn, debounced) +
# systemd user timer (every 15 min backstop). flock serializes so
# concurrent firings can't race.
#
# Order:
#   1. git pull --ff-only on both repos        — pick up any remote reorg
#   2. skills/scripts/install-local.sh         — refresh ~/.claude + ~/.codex
#                                                 symlinks from the current
#                                                 source-tree organization
#                                                 (idempotent via `ln -sfn`)
#   3. skills/scripts/sync-claude-desktop-mcps.sh — propagate ~/.claude.json
#                                                 mcpServers into Desktop's
#                                                 config (Claude Code → Desktop)
#   4. skills/scripts/auto-push.sh             — commit+push skills repo
#   5. mcps/scripts/refresh-all.sh             — refresh mcps snapshots
#   6. mcps/scripts/auto-push.sh               — commit+push mcps repo
#   7. sweep broken symlinks under ~/.claude/skills + ~/.codex/skills
#      (catches deleted-from-source skills; `ln -sfn` already handles moves)
#
# Each auto-push is a no-op when its tracked paths are unchanged (built-in
# git diff --cached --quiet check), so per-turn firing is cheap.
#
# Best-effort: never blocks the session. Errors logged to
# ~/.cache/recodeee-sync.log only.
# Kill switch: export RECODEEE_SYNC_OFF=1.

set -euo pipefail

if [[ "${RECODEEE_SYNC_OFF:-0}" == "1" ]]; then
  exit 0
fi

LOCK_FILE="/tmp/recodeee-sync.lock"
LOG_FILE="${HOME}/.cache/recodeee-sync.log"
mkdir -p "$(dirname "$LOG_FILE")"

SKILLS="${HOME}/Documents/recodeee/skills"
MCPS="${HOME}/Documents/recodeee/mcps"

exec 9>"$LOCK_FILE"
if ! flock -n 9; then
  exit 0
fi

stamp() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
log()   { echo "[$(stamp)] $*" >> "$LOG_FILE"; }

log "sync start"

# Pull remote changes first (multi-machine workflows). --ff-only refuses on
# divergence, leaving conflict resolution to the human — never auto-merge.
( cd "$SKILLS" && git pull --ff-only ) >> "$LOG_FILE" 2>&1 || log "skills pull skipped (likely diverged or offline)"
( cd "$MCPS"   && git pull --ff-only ) >> "$LOG_FILE" 2>&1 || log "mcps pull skipped (likely diverged or offline)"

# Refresh local symlinks so any source-tree reorg (local or just pulled)
# materializes in ~/.claude/skills and ~/.codex/skills before we push.
# install-local.sh is idempotent via `ln -sfn` — no .backup.* clutter.
if [[ -x "$SKILLS/scripts/install-local.sh" ]]; then
  "$SKILLS/scripts/install-local.sh" >> "$LOG_FILE" 2>&1 || log "install-local failed"
fi

# Propagate ~/.claude.json mcpServers into Claude Desktop's config so MCPs
# added via `claude mcp add` flow into the desktop app on its next restart.
# Idempotent — only writes when content changed.
if [[ -x "$SKILLS/scripts/sync-claude-desktop-mcps.sh" ]]; then
  "$SKILLS/scripts/sync-claude-desktop-mcps.sh" >> "$LOG_FILE" 2>&1 || log "claude-desktop mcp sync failed"
fi

# MCP + plugin snapshots are owned by recodeee/mcps (sole source of truth).
# skills/scripts/sync-mcps.sh was removed 2026-05-09 to dedup; the skills
# repo references mcps/ via README pointers. mcps/scripts/refresh-all.sh
# below regenerates the canonical snapshots.

if [[ -x "$SKILLS/scripts/auto-push.sh" ]]; then
  "$SKILLS/scripts/auto-push.sh" >> "$LOG_FILE" 2>&1 || log "skills auto-push failed"
fi

if [[ -x "$MCPS/scripts/refresh-all.sh" ]]; then
  ( cd "$MCPS" && "$MCPS/scripts/refresh-all.sh" ) >> "$LOG_FILE" 2>&1 || log "mcps refresh-all failed"
fi

if [[ -x "$MCPS/scripts/auto-push.sh" ]]; then
  "$MCPS/scripts/auto-push.sh" >> "$LOG_FILE" 2>&1 || log "mcps auto-push failed"
fi

# Sweep BROKEN symlinks (target no longer exists). Catches:
#   - skills deleted from the source tree
#   - any leftover `.backup.*` symlinks from older install-script versions
# `-xtype l` matches symlinks whose target doesn't resolve. Real skill
# symlinks point to existing dirs and are never touched.
find "${HOME}/.claude/skills" "${HOME}/.codex/skills" -maxdepth 1 \
  -xtype l -delete 2>>"$LOG_FILE" || true

log "sync done"
exit 0
