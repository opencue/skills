---
name: db-migrate
description: >-
  Apply pending Medusa database migrations via `npx medusa db:migrate`.
  Use when user says /medusa-dev:db-migrate, run migrations, apply
  pending migrations, or after running /db-generate to bring the
  database up to date. Reports applied count plus any errors.
allowed-tools: Bash(npx medusa db:migrate:*)
---

# Run Database Migrations

Execute the Medusa database migration command to apply pending migrations.

Use the Bash tool to execute: `npx medusa db:migrate`

Report the migration results to the user, including:

- Number of migrations applied
- Any errors that occurred
- Success confirmation
