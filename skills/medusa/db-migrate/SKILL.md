---
name: db-migrate
description: >-
  Use when user says "medusa db:migrate" or "run migrations". Medusa migration apply: env checks, commands, rollback risk.
---

# Run Database Migrations

Execute the Medusa database migration command to apply pending migrations.

Use the Bash tool to execute: `npx medusa db:migrate`

Report the migration results to the user, including:

- Number of migrations applied
- Any errors that occurred
- Success confirmation
