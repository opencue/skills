#!/usr/bin/env bash
# load-env.sh — secret + config resolver for the bash pipeline (Mode B in
# SKILL.md). Sourced by run-pipeline.sh.
#
# IMPORTANT — the recodee bouncer MCP (Phase 1, PR #1655) is agent-only by
# spec design: vault introspection (`vault.get(name)`) is forbidden, so there
# is no shell-side fetch path. Agent-driven runs (Claude / Codex) call the
# bouncer MCP directly and skip this script entirely for wrapped providers.
# This script handles non-agent runs (CI / cron / manual) and unwrapped
# providers (AWS-S3, Medusa-admin-API — Phase 2, not yet landed).
#
# Resolution order (first hit wins, per env var):
#   1. process env (already exported)
#   2. ~/.config/medusa-image-pipeline/<shop>.env  (chmod 600)
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

# --- Step 2: per-shop config file ---
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
  echo "load-env: set in env or in $CONFIG_FILE" >&2
  return 4 2>/dev/null || exit 4
fi

# Normalize: trailing slash on prefix, no trailing slash on public base
S3_PREFIX="${S3_PREFIX%/}/"
S3_PUBLIC_BASE="${S3_PUBLIC_BASE%/}"
export S3_PREFIX S3_PUBLIC_BASE

return 0 2>/dev/null || true
