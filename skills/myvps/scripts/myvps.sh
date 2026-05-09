#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: myvps.sh <schema_name>

Create a remote Supabase schema via SSH.

Schema rules:
  - start with a lowercase letter
  - use only lowercase letters, numbers, and underscores

Environment variables:
  SUPA_SCHEMA_SSH_TARGET   SSH target (default: root@62.72.35.11)
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

ssh_target="${SUPA_SCHEMA_SSH_TARGET:-root@62.72.35.11}"
remote_cmd="${SUPA_SCHEMA_REMOTE_CMD:-supabase-create-schema}"

echo "Creating schema '$schema_name' on $ssh_target..."
exec ssh "$ssh_target" "$remote_cmd" "$schema_name"
