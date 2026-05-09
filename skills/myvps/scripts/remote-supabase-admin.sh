#!/usr/bin/env bash
set -euo pipefail

ssh_target="${SUPA_SCHEMA_SSH_TARGET:-root@62.72.35.11}"
create_cmd="${SUPA_SCHEMA_REMOTE_CREATE_CMD:-supabase-create-schema}"
apply_cmd="${SUPA_SCHEMA_REMOTE_APPLY_CMD:-supabase-apply-sql}"

usage() {
  cat <<'USAGE'
Usage:
  remote-supabase-admin.sh create-schema <schema_name>
  remote-supabase-admin.sh apply-schema-sql <schema_name> <local_sql_file|->
  remote-supabase-admin.sh apply-sql <local_sql_file|->

Commands:
  create-schema     Create a remote schema.
  apply-schema-sql  Apply SQL with temporary search_path set to the schema.
  apply-sql         Apply SQL without forcing schema search_path.

Schema rules:
  - start with a lowercase letter
  - use only lowercase letters, numbers, and underscores

Notes:
  - Use '-' as local_sql_file to read SQL from stdin.
  - Prefer local .sql files over long inline SQL.

Environment variables:
  SUPA_SCHEMA_SSH_TARGET            SSH target (default: root@62.72.35.11)
  SUPA_SCHEMA_REMOTE_CREATE_CMD     Create command (default: supabase-create-schema)
  SUPA_SCHEMA_REMOTE_APPLY_CMD      Apply command (default: supabase-apply-sql)
USAGE
}

require_schema() {
  local schema="$1"
  if ! [[ "$schema" =~ ^[a-z][a-z0-9_]*$ ]]; then
    echo "Error: invalid schema name '$schema'. Required pattern: ^[a-z][a-z0-9_]*$" >&2
    exit 2
  fi
}

require_file_or_stdin() {
  local input="$1"
  if [[ "$input" == "-" ]]; then
    return 0
  fi
  if [[ ! -f "$input" ]]; then
    echo "Error: SQL file not found: $input" >&2
    exit 2
  fi
}

if [[ $# -lt 1 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

command="$1"
shift

case "$command" in
  create-schema)
    if [[ $# -ne 1 ]]; then
      usage >&2
      exit 2
    fi
    schema="$1"
    require_schema "$schema"
    echo "Creating schema '$schema' on $ssh_target..."
    exec ssh "$ssh_target" "$create_cmd" "$schema"
    ;;

  apply-schema-sql)
    if [[ $# -ne 2 ]]; then
      usage >&2
      exit 2
    fi
    schema="$1"
    sql_input="$2"
    require_schema "$schema"
    require_file_or_stdin "$sql_input"

    echo "Applying SQL to schema '$schema' on $ssh_target..."
    if [[ "$sql_input" == "-" ]]; then
      exec ssh "$ssh_target" "$apply_cmd" --schema "$schema" -
    else
      exec ssh "$ssh_target" "$apply_cmd" --schema "$schema" - < "$sql_input"
    fi
    ;;

  apply-sql)
    if [[ $# -ne 1 ]]; then
      usage >&2
      exit 2
    fi
    sql_input="$1"
    require_file_or_stdin "$sql_input"

    echo "Applying SQL (no forced schema search_path) on $ssh_target..."
    if [[ "$sql_input" == "-" ]]; then
      exec ssh "$ssh_target" "$apply_cmd" -
    else
      exec ssh "$ssh_target" "$apply_cmd" - < "$sql_input"
    fi
    ;;

  *)
    echo "Error: unknown command '$command'" >&2
    usage >&2
    exit 2
    ;;
esac
