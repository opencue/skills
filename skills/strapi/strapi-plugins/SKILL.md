---
name: strapi-plugins
description: 'Use when developing a Strapi v5 plugin: scaffolding with @strapi/sdk-plugin, the server + admin panel structure, registering it, and building/publishing.'
tags: [strapi, plugins, sdk-plugin, backend, admin-panel]
---

# Strapi Plugins

Build a Strapi v5 plugin to extend the server, the admin panel, or both.

## Use This Skill For

- Scaffolding a new plugin with the Plugin SDK
- Understanding the server-side vs admin-side structure
- Registering a local plugin and building it for publish

## Prerequisites

- A Strapi v5 project to host the plugin during development
- The Plugin SDK: `@strapi/sdk-plugin` (run via `npx` / `yarn dlx`)
- For installing community plugins instead of writing one, use the
  Marketplace npx command shown on each plugin's page

## Scaffold

```bash
npx @strapi/sdk-plugin@latest init my-strapi-plugin
# or: yarn dlx @strapi/sdk-plugin init my-strapi-plugin
```

This generates a plugin package with separate server and admin entry points.
Keep each concern in its own folder (the generated layout) rather than one
entry file.

```
my-strapi-plugin/
├── admin/src/         admin panel UI (React) — index.ts register()/bootstrap()
├── server/src/        controllers, services, routes, content-types, register/bootstrap
├── strapi-server.ts   server entry
├── strapi-admin.ts    admin entry
└── package.json
```

## Plugin SDK Commands

| Command | What it does |
|---|---|
| `@strapi/sdk-plugin init <name>` | Scaffold a new plugin package |
| `strapi-plugin build` | Build the plugin for publishing |
| `strapi-plugin watch` | Rebuild on change during development |
| `strapi-plugin verify` | Check the package is publish-ready |

You can also scaffold individual pieces inside a host project with
`strapi generate plugin`.

## Register a Local Plugin

Enable the plugin in the host project's plugins config:

```ts title="config/plugins.ts"
export default {
  'my-plugin': {
    enabled: true,
    resolve: './src/plugins/my-strapi-plugin', // local path
  },
};
```

Server code reaches Strapi through `strapi` (e.g.
`strapi.documents(...)`, `strapi.plugin('my-plugin').service('x')`). Admin
code registers menu links, settings pages, and injection zones in
`admin/src/index.ts`.

## Build & Publish

```bash
cd my-strapi-plugin
npm run build          # strapi-plugin build
npm publish            # to NPM, then optionally submit to the Marketplace
```

Upgrading the SDK across majors (e.g. v5 → v6) can change config; check the
plugin's create-a-plugin guide before bumping.

## Rules

- Split server and admin concerns into their folders; do not cram everything
  into one entry file.
- Use the Document Service from server code, not raw DB access, unless you
  need the lower level.
- `enabled: true` plus a `resolve` path is required for local plugins to load.
- Run `verify` before publishing to catch a malformed package.

## Next Step

Model the content your plugin operates on with `building-with-strapi`, or ship
the project with `strapi-deploy`.
