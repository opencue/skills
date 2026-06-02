---
name: strapi-cli
description: 'Use when user says "Strapi CLI", "create a Strapi app", "strapi develop", "build/start Strapi", or "export/import Strapi data". Scaffold and run a Strapi v5 project.'
tags: [strapi, cli, cms, scaffolding, headless-cms]
---

# Strapi CLI

Scaffold, run, and manage a Strapi v5 project from the command line.

## Use This Skill For

- Creating a new Strapi project
- Running the dev server, building, and starting in production
- Exporting / importing / transferring content between environments
- Generating APIs, types, and listing routes/services
- Managing admin users from the terminal

## Prerequisites

- Node.js LTS and a package manager (`yarn` recommended; `npm` works but
  hides prompts for interactive commands like `admin:create-user`)
- Scaffolder: `create-strapi` (run via `npx`, no global install)
- In-project CLI: `@strapi/strapi`, invoked as `npm run strapi`,
  `yarn strapi`, or `npx strapi`

## Create a Project

```bash
npx create-strapi@latest my-strapi-project
cd my-strapi-project
npm run develop        # admin panel → http://localhost:1337/admin
```

`strapi new`, `strapi install`, and `strapi watch-admin` from v4 were
removed in v5. Use `create-strapi` to scaffold and `develop` for watch mode.

## Command Reference

The local `strapi` binary takes a category of subcommands. Prefix with your
package manager (`npm run strapi <cmd>` / `yarn strapi <cmd>`).

### Development

| Command | What it does |
|---|---|
| `strapi develop` | Dev server with file watcher + auto-restart. Content-Type Builder is available here. Add `--no-watch-admin` to disable admin hot reload. |
| `strapi start` | Production-style run. Content-Type Builder is disabled (no restarts). |
| `strapi build` | Build the admin panel for production. |
| `strapi console` | Open a REPL with the `strapi` instance loaded. |

### Data management

| Command | What it does |
|---|---|
| `strapi export` | Export content + config to `.tar` (optionally `.gz`, `.enc`). |
| `strapi import` | Import an export archive or unpacked directory (`-f <file>`). |
| `strapi transfer` | Stream data directly between two Strapi instances. |

### Code generation

| Command | What it does |
|---|---|
| `strapi generate` | Interactive generator: API, controller, service, content-type, plugin, policy, middleware. |
| `strapi ts:generate-types` | Regenerate TypeScript types from the schema. |
| `strapi openapi generate` | Emit an OpenAPI spec for your content API. |

### Cloud

| Command | What it does |
|---|---|
| `strapi login` / `logout` | Authenticate with Strapi Cloud. |
| `strapi deploy` | Deploy the project to Strapi Cloud. |

### Listing & admin

- `strapi routes:list`, `policies:list`, `middlewares:list`,
  `content-types:list`, `controllers:list`, `services:list`
- `strapi admin:create-user`, `admin:reset-user-password`,
  `admin:list-users` (use `yarn`, not `npm`, so prompts render)

## Rules

- Use `develop` while modeling content; `start` for production runs only.
- Run interactive admin commands with `yarn`, never `npm` (npm swallows the
  prompts).
- Treat exports as backups before a risky migration or upgrade.
- Never commit the generated `.env`, `APP_KEYS`, or admin tokens.

## Next Step

After the server is up, model content with `building-with-strapi`, or wire
an AI client with `strapi-mcp-setup`.
