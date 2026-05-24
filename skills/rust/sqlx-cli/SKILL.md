---
name: sqlx-cli
description: Use when managing database migrations or query caching for a Rust app using sqlx, sea-orm, or diesel.
allowed-tools: Bash(cargo:*), Bash(sqlx:*), Bash(sea-orm-cli:*), Bash(diesel:*)
---

# Rust DB Tooling

Migration + ORM CLIs.

## When to use
- **sqlx** (compile-time-checked queries, no ORM):
  - Init: `sqlx database create` (uses `DATABASE_URL`)
  - New migration: `sqlx migrate add <name>` (or `--source migrations/`)
  - Apply: `sqlx migrate run`
  - Offline cache (so build doesn't need live DB): `cargo sqlx prepare`
- **SeaORM** (full async ORM):
  - Generate entities from DB: `sea-orm-cli generate entity -o src/entity`
  - Migration: `sea-orm-cli migrate init` then `sea-orm-cli migrate up`
- **Diesel** (sync, mature, schema-first):
  - Setup: `diesel setup`
  - New migration: `diesel migration generate <name>`
  - Apply: `diesel migration run`

## Prerequisites
- sqlx-cli (with features matching your DB), sea-orm-cli, or diesel_cli
- `DATABASE_URL` env var (sqlx, diesel) or a `cli` config (SeaORM)
- For diesel: `libpq-dev` (postgres) or `libmysqlclient-dev` (mysql) build deps

## Notes
- sqlx's compile-time check is great but requires either a live DB at build time OR `cargo sqlx prepare` committing `.sqlx/` cache files. Commit them.
- Don't mix migration systems — pick one per project.
- For brand-new projects with an async stack, sqlx is the lightest path. SeaORM is the choice when you actually want an ORM. Diesel is sync — fine for CLI tools, awkward in async services.
