---
name: myvps
description: Use when asked to create PostgreSQL schemas or apply local SQL files to a remote self-hosted Supabase server over SSH. Connection details come from the SUPA_SCHEMA_SSH_TARGET environment variable.
---

# MyVPS

Manage remote Supabase schema setup and SQL application against a self-hosted Supabase host reached over SSH.

The SSH target is **never** hardcoded. Set it once per shell:

```bash
export SUPA_SCHEMA_SSH_TARGET="<user>@<host-or-alias>"
```

Use an SSH config alias (`~/.ssh/config` `Host` entry) so neither IP nor user need to live in commits, history, or prompts.

## Canonical SSH Commands

When creating a schema on the remote server:

```bash
ssh "$SUPA_SCHEMA_SSH_TARGET" supabase-create-schema <schema_name>
```

When applying a local SQL file to a target schema:

```bash
ssh "$SUPA_SCHEMA_SSH_TARGET" 'supabase-apply-sql --schema <schema_name> -' < <local_sql_file>
```

When applying a local SQL file without forcing `search_path`:

```bash
ssh "$SUPA_SCHEMA_SSH_TARGET" 'supabase-apply-sql -' < <local_sql_file>
```

## Preferred Order

```bash
ssh "$SUPA_SCHEMA_SSH_TARGET" supabase-create-schema client_one
ssh "$SUPA_SCHEMA_SSH_TARGET" 'supabase-apply-sql --schema client_one -' < ./schema.sql
ssh "$SUPA_SCHEMA_SSH_TARGET" 'supabase-apply-sql --schema client_one -' < ./seed.sql
ssh "$SUPA_SCHEMA_SSH_TARGET" 'supabase-apply-sql -' < ./global.sql
```

## Rules

- Prefer applying local `.sql` files over long inline SQL.
- Schema names must match: `^[a-z][a-z0-9_]*$`.
- Never write the host, IP, or remote username into committed files, scripts, or prompts.

## Bundled Scripts

Both wrappers fail fast if `SUPA_SCHEMA_SSH_TARGET` is unset.

Create schema (legacy shortcut):

```bash
bash <path-to-skill>/scripts/myvps.sh <schema_name>
```

Full admin wrapper:

```bash
bash <path-to-skill>/scripts/remote-supabase-admin.sh create-schema <schema_name>
bash <path-to-skill>/scripts/remote-supabase-admin.sh apply-schema-sql <schema_name> <local_sql_file>
bash <path-to-skill>/scripts/remote-supabase-admin.sh apply-sql <local_sql_file>
```

## Operations Note

If `API_EXTERNAL_URL` on the remote Supabase deployment still points to localhost, auth callbacks and email links will not resolve from the public network. Update that in the server's Supabase env config separately — out of scope for this skill.
