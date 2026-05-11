---
name: db-migrate
description: >-
  Use when user says "medusa db:migrate", "run migrations", or "apply Medusa migration" and
  needs Medusa migration guidance. Covers environment checks, commands, rollback risk, and
  verification.allowed-tools: Bash(npx medusa db:migrate:*)
---

# Run Database Migrations

Execute the Medusa database migration command to apply pending migrations.

Use the Bash tool to execute: `npx medusa db:migrate`

Report the migration results to the user, including:

- Number of migrations applied
- Any errors that occurred
- Success confirmation
