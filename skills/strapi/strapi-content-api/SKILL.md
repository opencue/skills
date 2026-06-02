---
name: strapi-content-api
description: 'Use when consuming a Strapi v5 backend over HTTP: REST endpoints, the populate/filters/sort/pagination params, GraphQL setup, API tokens, and permissions.'
tags: [strapi, rest-api, graphql, content-api, headless-cms]
---

# Strapi Content API

Query a Strapi v5 backend from a storefront, app, or script over REST or
GraphQL.

## Use This Skill For

- Calling the auto-generated REST endpoints
- Shaping responses with `populate`, `fields`, `filters`, `sort`, pagination
- Setting up and querying GraphQL
- Authenticating with API tokens and granting the right permissions

## Prerequisites

- A running Strapi instance (default `http://localhost:1337`)
- For protected data: an API token from admin → Settings → API Tokens
- For GraphQL: the `@strapi/plugin-graphql` package installed

## REST Endpoints

Strapi generates REST routes per content-type. Use the `pluralApiId` for
collection types and `singularApiId` for single types.

| Method | Collection route | Action |
|---|---|---|
| GET | `/api/:pluralApiId` | List documents |
| POST | `/api/:pluralApiId` | Create a document |
| GET | `/api/:pluralApiId/:documentId` | Get one document |
| PUT | `/api/:pluralApiId/:documentId` | Update a document |
| DELETE | `/api/:pluralApiId/:documentId` | Delete a document |

Single types drop the `documentId` segment (e.g. `GET /api/homepage`).
Entries are addressed by their 24-char `documentId`, not numeric `id`.

```bash
# list, then fetch one
curl http://localhost:1337/api/restaurants
curl http://localhost:1337/api/restaurants/abc123documentid
```

A list response wraps results in `{ data, meta }`, where `meta.pagination`
carries page info.

## Query Parameters

Nothing populates by default; relations, media, components, and dynamic
zones come back only when you ask, and only if the role has find permission
on them.

```bash
# populate relations + pick fields
curl "http://localhost:1337/api/restaurants?populate=*"
curl "http://localhost:1337/api/restaurants?populate[chef][fields][0]=name&fields[0]=title"

# filter, sort, paginate
curl "http://localhost:1337/api/restaurants?filters[city][\$eq]=Paris"
curl "http://localhost:1337/api/restaurants?sort=title:asc&pagination[page]=1&pagination[pageSize]=10"

# draft & publish
curl "http://localhost:1337/api/restaurants?status=published"
```

Common filter operators: `$eq`, `$ne`, `$lt`, `$gt`, `$contains`,
`$containsi`, `$in`, `$null`. Combine with `$and` / `$or`.

## GraphQL

```bash
yarn add @strapi/plugin-graphql      # or: npm install @strapi/plugin-graphql
```

One endpoint serves everything: `/graphql` (default). The playground is at
the same URL in dev. Dynamic zones are union types, so query their fields
with inline fragments (`... on ComponentCategoryName`).

```graphql
query {
  restaurants(filters: { city: { eq: "Paris" } }, sort: "title:asc") {
    documentId
    title
    chef { name }
  }
}
```

## Authentication & Permissions

- **Public role**: grant find/findOne per content-type in admin → Settings
  → Users & Permissions → Roles for unauthenticated reads.
- **API tokens**: send `Authorization: Bearer <token>` for read-only,
  full-access, or custom-scoped server-to-server calls.

```bash
curl -H "Authorization: Bearer $STRAPI_TOKEN" http://localhost:1337/api/orders
```

## Rules

- Address entries by `documentId`.
- Add `populate`/`fields` explicitly and grant matching permissions, or
  relations return empty.
- Never ship a full-access token to a browser client; use the public role or
  a narrowly scoped read-only token.
- URL-encode filter operators (`$eq`) in shells.

## Next Step

For AI clients that manage content directly instead of raw HTTP, set up
`strapi-mcp-setup`.
