#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: myvps.sh <schema_name>

Create a remote Supabase schema via SSH.

Schema rules:
  - start with a lowercase letter
  - use only lowercase letters, numbers, and underscores

Required environment variables:
  SUPA_SCHEMA_SSH_TARGET   SSH target (e.g. an alias from ~/.ssh/config)

Optional environment variables:
  SUPA_SCHEMA_REMOTE_CMD   Remote command (default: supabase-create-schema)
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 1 ]]; then
  usage >&2
  exit 2
fi

schema_name="$1"

if ! [[ "$schema_name" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "Error: invalid schema name '$schema_name'. Required pattern: ^[a-z][a-z0-9_]*$" >&2
  exit 2
fi

if [[ -z "${SUPA_SCHEMA_SSH_TARGET:-}" ]]; then
  echo "Error: SUPA_SCHEMA_SSH_TARGET is not set. Export it before running this script." >&2
  exit 2
fi

ssh_target="$SUPA_SCHEMA_SSH_TARGET"
remote_cmd="${SUPA_SCHEMA_REMOTE_CMD:-supabase-create-schema}"

echo "Creating schema '$schema_name' on remote target..."
exec ssh "$ssh_target" "$remote_cmd" "$schema_name"
