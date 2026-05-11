---
name: db-generate
description: >-
  Use when user says "medusa db:generate", "generate migration", or "Medusa migration file"
  and needs Medusa migration generation guidance. Covers model changes, commands, review, and
  validation.argument-hint: <module-name>
allowed-tools: Bash(npx medusa db:generate:*)
---

# Generate Database Migrations

Generate database migrations for the specified Medusa module.

The user will provide the module name as an argument (e.g., `brand`, `product`, `custom-module`).

For example: `/medusa-dev:db-generate brand`

Use the Bash tool to execute the command `npx medusa db:generate <module-name>`, replacing `<module-name>` with the provided argument.

Report the results to the user, including:

- The module name for which migrations were generated
- Migration file name or location
- Any errors or warnings
- Next steps (running `npx medusa db:migrate` to apply the migrations)
