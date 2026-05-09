#!/usr/bin/env bash
# load-env.sh — single source of truth for resolving secrets + config for the
# higgsfield → medusa pipeline. Sourced by run-pipeline.sh.
#
# Resolution order (first hit wins, per env var):
#   1. process env (already exported)
#   2. recodee bouncer MCP — `codex secret get <var> --scope <shop>` if available
#   3. ~/.config/medusa-image-pipeline/<shop>.env
#
# Usage:
#   SHOP="$1" source "$(dirname "$0")/load-env.sh"
#
# Required exports after sourcing:
#   MEDUSA_BACKEND_URL, MEDUSA_SECRET_KEY,
#   S3_BUCKET, S3_REGION, S3_PREFIX, S3_PUBLIC_BASE,
#   AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY  (or AWS_PROFILE)

set -euo pipefail

SHOP="${SHOP:-${1:-}}"
[[ -z "$SHOP" ]] && { echo "load-env: SHOP arg required" >&2; return 2 2>/dev/null || exit 2; }

CONFIG_FILE="${MEDUSA_PIPELINE_CONFIG:-$HOME/.config/medusa-image-pipeline/$SHOP.env}"

# --- Step 1: process env vars stay as-is ---
# Nothing to do; bash already has them.

# --- Step 2: bouncer MCP (placeholder until recodee/agent-secret-vault-mcp lands) ---
# When the MCP exposes a CLI shim like `codex secret get`, populate any unset
# vars from it here. Today this block is a no-op fall-through.
if command -v recodee-vault >/dev/null 2>&1; then
  for v in MEDUSA_BACKEND_URL MEDUSA_SECRET_KEY S3_BUCKET S3_REGION S3_PREFIX S3_PUBLIC_BASE AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY; do
    if [[ -z "${!v:-}" ]]; then
      val=$(recodee-vault get "$v" --scope "$SHOP" 2>/dev/null || true)
      [[ -n "$val" ]] && export "$v=$val"
    fi
  done
fi

# --- Step 3: config file ---
if [[ -f "$CONFIG_FILE" ]]; then
  perm=$(stat -c "%a" "$CONFIG_FILE" 2>/dev/null || stat -f "%Lp" "$CONFIG_FILE")
  if [[ "$perm" != "600" && "$perm" != "400" ]]; then
    echo "load-env: refusing to read $CONFIG_FILE (perms $perm — must be 600 or 400)" >&2
    return 3 2>/dev/null || exit 3
  fi
  set -a
  # shellcheck source=/dev/null
  . "$CONFIG_FILE"
  set +a
fi

# --- Validate required vars (without echoing values) ---
missing=()
for v in MEDUSA_BACKEND_URL MEDUSA_SECRET_KEY S3_BUCKET S3_REGION S3_PREFIX S3_PUBLIC_BASE; do
  [[ -z "${!v:-}" ]] && missing+=("$v")
done

# AWS auth: either explicit keys OR an AWS_PROFILE
if [[ -z "${AWS_ACCESS_KEY_ID:-}" && -z "${AWS_PROFILE:-}" ]]; then
  missing+=("AWS_ACCESS_KEY_ID or AWS_PROFILE")
fi

if (( ${#missing[@]} > 0 )); then
  echo "load-env: missing required config: ${missing[*]}" >&2
  echo "load-env: set in env, in vault, or in $CONFIG_FILE" >&2
  return 4 2>/dev/null || exit 4
fi

# Normalize: trailing slash on prefix, no trailing slash on public base
S3_PREFIX="${S3_PREFIX%/}/"
S3_PUBLIC_BASE="${S3_PUBLIC_BASE%/}"
export S3_PREFIX S3_PUBLIC_BASE

return 0 2>/dev/null || true
