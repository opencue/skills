---
name: building-with-strapi
description: 'Use when building a Strapi v5 backend: project structure, content-types, components, dynamic zones, the Content-Type Builder, and Document Service queries in custom code.'
tags: [strapi, cms, content-types, document-service, backend]
---

# Building With Strapi

Model content and customize the backend of a Strapi v5 project.

## Use This Skill For

- Understanding the project layout and where code lives
- Creating content-types, components, and dynamic zones
- Querying and mutating content from custom code via the Document Service

## Prerequisites

- A running Strapi v5 project in dev mode (`npm run develop`). See
  `strapi-cli` to scaffold one.
- Content-Type Builder only works in `develop` mode (it writes schema files
  and restarts the server).

## Project Structure

```
my-strapi-project/
├── config/            server.ts, database.ts, admin.ts, api.ts, plugins.ts, middlewares.ts
├── src/
│   ├── api/<name>/     content-types/, controllers/, services/, routes/
│   ├── components/     reusable field groups
│   ├── extensions/     overrides for installed plugins
│   ├── plugins/        local plugins
│   └── index.ts        register() / bootstrap() lifecycle
├── database/migrations/
└── public/uploads/     media library files
```

Each entry under `src/api/<name>/` is one content-type with its schema,
controller, service, and routes.

## Modeling Content

Build content-types in the admin **Content-Type Builder**
(`/admin/plugins/content-type-builder`):

- **Collection type**: many entries (e.g. `restaurant` → `/api/restaurants`).
- **Single type**: one entry (e.g. `homepage` → `/api/homepage`).
- **Component**: a reusable group of fields embedded in types.
- **Dynamic zone**: a slot that accepts a chosen list of components per entry.

The builder writes `schema.json` files under
`src/api/<name>/content-types/`. Commit those; they are your schema source
of truth.

## documentId, Not id

Strapi 5 identifies every entry by a 24-character `documentId`, stable across
locales and draft/published versions. The numeric `id` is a physical record
detail and may disappear in future versions.

- Query and relate by `documentId`.
- Treat `id` as legacy; do not hardcode it in clients or relations.

## Document Service API (in custom code)

Inside controllers, services, and plugins, use the Document Service. It sits
above the Query Engine and understands components, dynamic zones, draft &
publish, and i18n.

```ts
// list (nothing populates by default — ask for it)
const articles = await strapi.documents('api::article.article').findMany({
  filters: { title: { $containsi: 'strapi' } },
  populate: { cover: true, author: { fields: ['name'] } },
  sort: 'publishedAt:desc',
  status: 'published',
});

// fetch one by documentId
const one = await strapi.documents('api::article.article').findOne({
  documentId,
  populate: ['cover'],
});

// create / update / delete
const created = await strapi.documents('api::article.article').create({ data });
await strapi.documents('api::article.article').update({ documentId, data });
await strapi.documents('api::article.article').delete({ documentId });

// draft & publish (when enabled on the type)
await strapi.documents('api::article.article').publish({ documentId });
await strapi.documents('api::article.article').unpublish({ documentId });
```

Need raw DB access below the content model? Drop to the Query Engine
(`strapi.db.query(...)`), but prefer the Document Service for anything that
touches components, dynamic zones, or publication state.

## Rules

- Model in `develop`; the builder is disabled in `start`.
- Always pass `populate`/`fields` explicitly; defaults return top-level
  scalars only.
- Use the Document Service over the removed Entity Service path and over raw
  Query Engine unless you specifically need lower-level access.
- Commit `schema.json` files; they define the data model.

## Next Step

Expose this content over HTTP with `strapi-content-api`, or package custom
features as a plugin with `strapi-plugins`.
