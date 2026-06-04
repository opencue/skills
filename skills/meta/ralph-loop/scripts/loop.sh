#!/usr/bin/env bash
# ralph-loop — a guarded "Ralph Wiggum" autonomous loop for Claude Code.
#
# Re-feeds one goal prompt to `claude` until a stop-check command succeeds, an
# iteration cap is hit, or you Ctrl-C. The stop-check is the only source of
# truth for "done" — keep it honest (tests/build), never a vibe.
#
# Usage:
#   loop.sh --prompt GOAL.md --until "bun test" [--max 50] [--sleep 2]
#           [--checkpoint] [--yolo] [--agent claude]
#
#   --prompt FILE    File whose contents are fed to the agent each round (required).
#   --until "CMD"    Shell command; loop stops when it exits 0 (required).
#   --max N          Hard cap on iterations (default 50). Prevents runaway spin.
#   --sleep S        Seconds between rounds (default 2).
#   --checkpoint     git add -A && commit after each round (recoverable progress).
#   --yolo           Pass --dangerously-skip-permissions (UNATTENDED). Sandbox only.
#   --agent CMD      Agent CLI to invoke (default: claude).
#
# Exit: 0 if the stop-check passed; 1 if the iteration cap was reached first.
set -euo pipefail

PROMPT=""; UNTIL=""; MAX=50; SLEEP=2; CHECKPOINT=0; YOLO=0; AGENT="claude"
while [ $# -gt 0 ]; do
  case "$1" in
    --prompt) PROMPT="${2:?}"; shift 2;;
    --until) UNTIL="${2:?}"; shift 2;;
    --max) MAX="${2:?}"; shift 2;;
    --sleep) SLEEP="${2:?}"; shift 2;;
    --checkpoint) CHECKPOINT=1; shift;;
    --yolo) YOLO=1; shift;;
    --agent) AGENT="${2:?}"; shift 2;;
    -h|--help) sed -n '2,22p' "$0"; exit 0;;
    *) echo "unknown arg: $1" >&2; exit 2;;
  esac
done

[ -n "$PROMPT" ] || { echo "error: --prompt is required" >&2; exit 2; }
[ -f "$PROMPT" ] || { echo "error: prompt file not found: $PROMPT" >&2; exit 2; }
[ -n "$UNTIL" ]  || { echo "error: --until <stop-check command> is required (the Iron Law)" >&2; exit 2; }
command -v "$AGENT" >/dev/null || { echo "error: agent CLI '$AGENT' not on PATH" >&2; exit 2; }

AGENT_FLAGS=(-p)
if [ "$YOLO" -eq 1 ]; then
  echo "⚠️  --yolo: running with --dangerously-skip-permissions. Sandbox only." >&2
  AGENT_FLAGS+=(--dangerously-skip-permissions)
fi

# Stop-check first: if we're already done, do nothing.
if eval "$UNTIL" >/dev/null 2>&1; then
  echo "✓ stop-check already passes — nothing to do."; exit 0
fi

i=0
while [ "$i" -lt "$MAX" ]; do
  i=$((i + 1))
  echo "── ralph round $i/$MAX ($(date +%H:%M:%S)) ──"
  # Feed the goal prompt to the agent. Each round sees prior file changes + git.
  "$AGENT" "${AGENT_FLAGS[@]}" "$(cat "$PROMPT")" || echo "  (agent exited non-zero — continuing)"

  if [ "$CHECKPOINT" -eq 1 ] && git rev-parse --git-dir >/dev/null 2>&1; then
    git add -A && git commit -q -m "ralph: round $i" --no-verify 2>/dev/null \
      && echo "  checkpoint: $(git rev-parse --short HEAD)" || echo "  (nothing to checkpoint)"
  fi

  if eval "$UNTIL" >/dev/null 2>&1; then
    echo "✓ stop-check passed after $i round(s): $UNTIL"; exit 0
  fi
  sleep "$SLEEP"
done

echo "✗ hit iteration cap ($MAX) without passing stop-check: $UNTIL" >&2
exit 1
