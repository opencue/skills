---
name: strapi-deploy
description: 'Use when deploying a Strapi v5 backend: Strapi Cloud via the CLI, or self-hosting with NODE_ENV=production build/start, pm2, env vars, and a production database.'
tags: [strapi, deployment, strapi-cloud, self-host, pm2]
---

# Strapi Deploy

Deploy a Strapi v5 project to Strapi Cloud or your own server.

## Use This Skill For

- Deploying to Strapi Cloud from the CLI
- Self-hosting: production build, start, process management, env config
- Moving content between environments

## Prerequisites

- A built project (`npm run build`) that runs locally
- For Cloud: a Strapi Cloud account and the project-local `strapi` CLI
- For self-host: Node.js LTS on the server, a production database, and a
  process manager (`pm2` recommended)

## Option A: Strapi Cloud

```bash
npm run strapi login     # or: yarn strapi login
npm run strapi deploy
```

Cloud handles the build, database, and hosting. Use this when you want the
fastest path and do not need to manage infrastructure.

## Option B: Self-Host

### 1. Configure for production

Set production env vars (never commit them): `NODE_ENV=production`,
`APP_KEYS`, `API_TOKEN_SALT`, `ADMIN_JWT_SECRET`, `JWT_SECRET`, and the
database connection (`DATABASE_*`). Point `config/database.ts` at a real
database (PostgreSQL/MySQL), not SQLite, for production.

### 2. Build

```bash
NODE_ENV=production npm run build      # or: yarn build
```

On Windows, wrap with cross-env: `cross-env NODE_ENV=production npm run build`.

### 3. Start

```bash
NODE_ENV=production npm run start      # or: yarn start
```

### 4. Keep it running with pm2

```bash
npm install -g pm2
pm2 start npm --name strapi -- run start
pm2 save
pm2 startup            # generate the boot script
```

Put a reverse proxy (nginx/Traefik) in front for TLS. If you self-host on
Coolify, the `coolify` skill covers the container + proxy + env workflow.

## Moving Content Between Environments

```bash
# back up before deploy
npm run strapi export -- --file backup.tar.gz

# or stream straight to another instance
npm run strapi transfer -- --to https://prod.example.com/admin
```

## Rules

- Production runs with `NODE_ENV=production`; SQLite is for local dev only.
- All secrets come from env on the server, never the repo.
- Build before start; a stale or missing admin build serves a broken panel.
- Export (or transfer) as a backup before every production deploy.

## Next Step

After deploy, verify the live API with `strapi-content-api`, or wire the
production MCP endpoint with `strapi-mcp-setup`.
