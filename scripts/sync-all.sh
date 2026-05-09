#!/usr/bin/env bash
# Orchestrate sync of skills + mcps repos to GitHub.
#
# Cadence approved by user 2026-05-09: Stop hook (per-turn, debounced) +
# systemd user timer (every 15 min backstop). flock serializes so
# concurrent firings can't race.
#
# Order:
#   1. skills/scripts/sync-mcps.sh   — refresh MCP snapshots into skills/mcps/
#   2. skills/scripts/auto-push.sh   — commit+push skills repo
#   3. mcps/scripts/refresh-all.sh   — refresh mcps snapshots
#   4. mcps/scripts/auto-push.sh     — commit+push mcps repo
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

log "sync done"
exit 0
