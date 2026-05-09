#!/usr/bin/env bash
# soul-lint: human-readable summary of soul SKILL.md health.
# Modes:
#   soul-lint            — human output (default), exit 1 on errors
#   soul-lint --quiet    — only errors, silent on clean
#   soul-lint --json     — raw JSON from the linter
# Called by sync-all.sh in --quiet mode every 15 min.

set -euo pipefail

MODE="${1:-human}"
LINTER="${HOME}/Documents/soul/mcps/mcps/soul-skills/lint.py"

if [[ ! -f "$LINTER" ]]; then
  echo "soul-lint: linter not found: $LINTER" >&2
  exit 2
fi

# linter is stdlib-only; plain python3 works. PEP 723 shebang is a fallback
# when running under uv. Prefer plain python3 here for portability.
# lint.py exits 1 when it finds errors (not when it crashes). Capture stdout
# regardless of exit code; we'll classify pass/fail from error_count below.
if command -v python3 >/dev/null 2>&1; then
  result=$(python3 "$LINTER" 2>/dev/null || true)
elif command -v uv >/dev/null 2>&1; then
  result=$(uv run --quiet "$LINTER" 2>/dev/null || true)
else
  echo "soul-lint: python3 or uv required" >&2
  exit 2
fi

if [[ -z "$result" ]] || ! echo "$result" | jq empty 2>/dev/null; then
  echo "soul-lint: linter produced no parsable output (it crashed)" >&2
  exit 2
fi

err_count=$(echo "$result" | jq -r '.error_count // 0')
warn_count=$(echo "$result" | jq -r '.warning_count // 0')
checked=$(echo "$result" | jq -r '.checked // 0')

case "$MODE" in
  --json)
    echo "$result"
    ;;
  --quiet)
    if [[ "$err_count" -gt 0 ]]; then
      echo "$result" | jq -r '.errors[] | "[soul-lint ERROR] \(.path): \(.issue)"' >&2
      exit 1
    fi
    ;;
  *)
    echo "soul-lint: checked $checked skill(s)"
    if [[ "$err_count" -gt 0 ]]; then
      echo "$result" | jq -r '.errors[] | "  [ERROR] \(.path): \(.issue)"' >&2
    fi
    if [[ "$warn_count" -gt 0 ]]; then
      echo "$result" | jq -r '.warnings[] | "  [warn]  \(.path): \(.issue)"' >&2
    fi
    if [[ "$err_count" -eq 0 && "$warn_count" -eq 0 ]]; then
      echo "  all clean"
    else
      echo "  $err_count error(s), $warn_count warning(s)"
    fi
    [[ "$err_count" -gt 0 ]] && exit 1 || exit 0
    ;;
esac
