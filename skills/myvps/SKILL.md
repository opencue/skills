---
name: myvps
description: Use when asked to create PostgreSQL schemas or apply local SQL files to the remote self-hosted Supabase server at `root@62.72.35.11` over SSH.
---

# MyVPS

Manage remote Supabase schema setup and SQL application on `root@62.72.35.11`.

## Canonical SSH Commands

When creating a schema on the remote server:

```bash
ssh root@62.72.35.11 supabase-create-schema <schema_name>
```

When applying a local SQL file to a target schema:

```bash
ssh root@62.72.35.11 'supabase-apply-sql --schema <schema_name> -' < <local_sql_file>
```

When applying a local SQL file without forcing `search_path`:

```bash
ssh root@62.72.35.11 'supabase-apply-sql -' < <local_sql_file>
```

## Preferred Order

```bash
ssh root@62.72.35.11 supabase-create-schema client_one
ssh root@62.72.35.11 'supabase-apply-sql --schema client_one -' < ./schema.sql
ssh root@62.72.35.11 'supabase-apply-sql --schema client_one -' < ./seed.sql
ssh root@62.72.35.11 'supabase-apply-sql -' < ./global.sql
```

## Rules

- Prefer applying local `.sql` files over long inline SQL.
- Schema names must match: `^[a-z][a-z0-9_]*$`.
- Remote Supabase public URL: `http://62.72.35.11:8000`.

## Bundled Scripts

Use script wrappers when convenient.

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

`API_EXTERNAL_URL` may still be set to localhost in some deployments. If auth callbacks or email links must use the public IP, update that separately in the server's Supabase env config.
