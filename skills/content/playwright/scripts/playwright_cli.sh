#!/usr/bin/env bash
set -euo pipefail

if ! command -v npx >/dev/null 2>&1; then
  echo "Error: npx is required but not found on PATH." >&2
  exit 1
fi

cleanup_stale_playwright_daemons() {
  local max_age_seconds="${PLAYWRIGHT_CLI_DAEMON_MAX_AGE_SECONDS:-600}"

  [[ "${PLAYWRIGHT_CLI_CLEANUP_STALE_DAEMONS:-1}" == "1" ]] || return 0
  [[ "$max_age_seconds" =~ ^[0-9]+$ ]] || max_age_seconds=600

  # The daemon can leave a headless Chrome/SwiftShader process burning CPU for
  # hours. Reap only old Playwright CLI daemon process groups, never user Chrome.
  ps -eo pid=,pgid=,etimes=,args= | while read -r pid pgid etimes args; do
    [[ "$args" == *"playwright-core/lib/entry/cliDaemon.js default"* ]] || continue
    (( etimes >= max_age_seconds )) || continue
    kill -TERM "-$pgid" >/dev/null 2>&1 || true
  done

  ps -eo pid=,pgid=,etimes=,args= | while read -r pid pgid etimes args; do
    [[ "$args" == *"/tmp/playwright_chromiumdev_profile-"* ]] || continue
    [[ "$args" == *"--headless"* ]] || continue
    (( etimes >= max_age_seconds )) || continue
    kill -TERM "-$pgid" >/dev/null 2>&1 || true
  done
}

cleanup_stale_playwright_daemons
(
  max_age_seconds="${PLAYWRIGHT_CLI_DAEMON_MAX_AGE_SECONDS:-600}"
  [[ "${PLAYWRIGHT_CLI_CLEANUP_STALE_DAEMONS:-1}" == "1" ]] || exit 0
  [[ "$max_age_seconds" =~ ^[0-9]+$ ]] || max_age_seconds=600
  sleep "$max_age_seconds"
  cleanup_stale_playwright_daemons
) >/dev/null 2>&1 &

has_session_flag="false"
for arg in "$@"; do
  case "$arg" in
    --session|--session=*)
      has_session_flag="true"
      break
      ;;
  esac
done

cmd=(npx --yes --package @playwright/cli playwright-cli)
if [[ "${has_session_flag}" != "true" && -n "${PLAYWRIGHT_CLI_SESSION:-}" ]]; then
  cmd+=(--session "${PLAYWRIGHT_CLI_SESSION}")
fi
cmd+=("$@")

exec "${cmd[@]}"
