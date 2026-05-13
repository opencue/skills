#!/usr/bin/env bash
# codex_fleet_login.sh — spawn kitty terminal(s) running `codex login`, capture
# the OAuth URL from each, and open it in the default browser.
#
# Mirrors the gx-cockpit / gx-fleet pattern: prefers Kitty remote control when
# we are already inside a Kitty session, otherwise spawns a fresh Kitty window.
#
# Usage:
#   codex_fleet_login.sh                 # one terminal
#   codex_fleet_login.sh --count 3       # three terminals, sequential
#   codex_fleet_login.sh --no-open       # don't auto-open URL, just print it
#   codex_fleet_login.sh --label foo     # tag log filenames
#   codex_fleet_login.sh --hold          # leave the kitty window open after exit
#
# Why sequential by default: `codex login` binds localhost:1455, so two logins
# at once collide. We launch one, wait for it to finish, then launch the next.

set -euo pipefail

COUNT=1
OPEN_URL=1
OPEN_MODE="incognito"     # incognito | default | none
LABEL=""
HOLD=1
PORT="${CODEX_LOGIN_PORT:-1455}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --count)         COUNT="$2"; shift 2 ;;
    --no-open)       OPEN_URL=0; shift ;;
    --open-default)  OPEN_MODE="default"; shift ;;
    --open-incognito) OPEN_MODE="incognito"; shift ;;
    --label)         LABEL="$2"; shift 2 ;;
    --hold)          HOLD=1; shift ;;
    --no-hold)       HOLD=0; shift ;;
    -h|--help)       sed -n '2,18p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

# Pick a browser launcher for the URL.
# Default: Chrome/Chromium --incognito (bypasses cache, extensions, and stale
# service workers on auth.openai.com that have been seen to render a blank
# page when the user's main profile is hot).
pick_browser_cmd() {
  case "$OPEN_MODE" in
    none)    echo ""; return ;;
    default) command -v xdg-open >/dev/null && echo "xdg-open" && return
             echo ""; return ;;
    incognito|*)
      for c in google-chrome google-chrome-stable chromium chromium-browser brave-browser; do
        if command -v "$c" >/dev/null; then
          echo "$c --incognito --new-window"
          return
        fi
      done
      # firefox private as fallback
      if command -v firefox >/dev/null; then
        echo "firefox --private-window"
        return
      fi
      # last resort: default opener (no incognito guarantee)
      command -v xdg-open >/dev/null && echo "xdg-open"
      ;;
  esac
}
BROWSER_CMD="$(pick_browser_cmd)"

command -v kitty >/dev/null || { echo "kitty not found on PATH" >&2; exit 1; }
command -v codex >/dev/null || { echo "codex not found on PATH" >&2; exit 1; }

LOG_DIR="${TMPDIR:-/tmp}/codex-fleet-login"
mkdir -p "$LOG_DIR"

# Detect Kitty remote-control availability (gx-fleet style).
KITTY_REMOTE=0
if [[ -n "${KITTY_LISTEN_ON:-}" ]] && kitty @ ls >/dev/null 2>&1; then
  KITTY_REMOTE=1
fi

extract_url() {
  grep -oE 'https://auth\.openai\.com/oauth/authorize\?[^[:space:]]+' "$1" \
    | head -n1 || true
}

spawn_one() {
  local idx="$1"
  local stamp
  stamp="$(date +%Y%m%d-%H%M%S)"
  local tag="${LABEL:+${LABEL}-}${idx}"
  local log="$LOG_DIR/codex-login-${stamp}-${tag}.log"
  local done_marker="${log}.done"

  : > "$log"

  echo "[fleet] window #${idx}  log=${log}"

  local hold_line='echo "[codex-fleet-login] codex login exited (status=$status). Press Enter to close."; read -r _'
  if (( HOLD == 0 )); then
    hold_line='exit $status'
  fi

  # The command that runs inside the kitty window.
  local inner_cmd
  # Resolve a non-guarded codex binary in the outer env so the kitty subshell
  # doesn't depend on its login-shell PATH (e.g. nvm not sourced under bash -lc).
  local codex_bin=""
  IFS=':' read -r -a _path_dirs <<< "$PATH"
  local _self_resolved=""
  if local _shim="$(command -v codex 2>/dev/null)"; then
    _self_resolved="$(readlink -f "$_shim" 2>/dev/null || echo "$_shim")"
  fi
  for _d in "${_path_dirs[@]}"; do
    [[ -z "$_d" ]] && continue
    local _c="$_d/codex"
    [[ -x "$_c" && ! -d "$_c" ]] || continue
    local _r
    _r="$(readlink -f "$_c" 2>/dev/null || echo "$_c")"
    if [[ "$_r" != "$_self_resolved" ]]; then
      codex_bin="$_c"
      break
    fi
  done
  # Fallback: pass through the name and let the inner shell resolve it.
  [[ -z "$codex_bin" ]] && codex_bin="codex"

  inner_cmd=$(cat <<EOF
clear
echo "[codex-fleet-login] account #${idx} — log: ${log}"
echo "[codex-fleet-login] codex: ${codex_bin}"
echo "[codex-fleet-login] running: codex login"
echo
CODEX_GUARD_BYPASS=1 "${codex_bin}" login 2>&1 | tee "${log}"
status=\${PIPESTATUS[0]}
touch "${done_marker}"
echo
${hold_line}
EOF
)

  if (( KITTY_REMOTE == 1 )); then
    kitty @ launch \
      --type=os-window \
      --title "codex-login-${tag}" \
      --keep-focus \
      bash -lc "$inner_cmd" >/dev/null
  else
    setsid kitty --title "codex-login-${tag}" \
      bash -lc "$inner_cmd" </dev/null >/dev/null 2>&1 &
    disown $! 2>/dev/null || true
  fi

  # Wait for the OAuth URL to appear in the log (codex prints it within ~1s).
  local url=""
  local waited=0
  while (( waited < 30 )); do
    url=$(extract_url "$log")
    [[ -n "$url" ]] && break
    sleep 1
    waited=$((waited+1))
  done

  if [[ -z "$url" ]]; then
    echo "[fleet] WARNING: no OAuth URL within 30s — check the kitty window" >&2
  else
    echo "[fleet] URL: $url"
    if (( OPEN_URL == 1 )); then
      if [[ -n "$BROWSER_CMD" ]]; then
        # shellcheck disable=SC2086
        ( nohup $BROWSER_CMD "$url" >/dev/null 2>&1 & )
        echo "[fleet] opened via: $BROWSER_CMD"
      else
        echo "[fleet] no browser launcher available — copy the URL manually"
      fi
    fi
  fi

  # Wait for codex login to finish (done marker), so the next iteration
  # doesn't collide on port ${PORT}.
  local max_wait=600   # 10 min for user to finish OAuth in browser
  waited=0
  while [[ ! -f "$done_marker" ]] && (( waited < max_wait )); do
    sleep 2
    waited=$((waited+2))
  done

  if [[ -f "$done_marker" ]]; then
    echo "[fleet] window #${idx} finished"
  else
    echo "[fleet] window #${idx} still running after ${max_wait}s — moving on" >&2
  fi
}

for ((i=1; i<=COUNT; i++)); do
  spawn_one "$i"
  if (( i < COUNT )); then
    echo "[fleet] cooling down 2s before next window..."
    sleep 2
  fi
done

echo "[fleet] done. Logs under ${LOG_DIR}/"
