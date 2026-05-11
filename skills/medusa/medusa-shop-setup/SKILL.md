---
name: medusa-shop-setup
description: >-
  Use when user says "new Medusa shop", "setup Medusa store", or "Medusa shop scaffold". Base template, backend, storefront, envs, deployment.
---

# Medusa Shop Setup

Use this skill for the workspace flow where a new Medusa v2 webshop is copied from:

```text
/home/deadpool/Documents/medusa-shops/base-template
```

Backend deploy target: Coolify on Hostinger VPS. Storefront deploy target: Hostinger shared hosting.

## Required Reading

Before changing files or running setup commands, read:

```text
/home/deadpool/Documents/medusa-shops/base-template/tutorial.md
/home/deadpool/Documents/medusa-shops/base-template/DEPLOY.md
```

## Operating Rules

- Do not edit `base-template` product code unless the user asks to improve the template itself.
- Never commit real `.env` files or real secrets.
- Use placeholders in tracked docs and examples.
- Use `pnpm configure:env` as the first path for local env generation.
- Treat the generated backend `.env` as the source for Coolify env sync.
- Keep one shop = one DB schema.
- Verify generated env output before claiming setup is ready.

## Minimal Flow

When the user provides only a domain, derive defaults:

| Input | Default |
| --- | --- |
| domain | user-provided domain, normalized without protocol or `www.` |
| admin host | `admin.<domain>` |
| shop slug | first domain label |
| DB schema | shop slug with dashes changed to underscores |
| backend URL | `https://admin.<domain>` |
| storefront URL | `https://<domain>` |

Use:

```bash
cd /home/deadpool/Documents/medusa-shops/<new-shop>
pnpm configure:env -- --domain <domain>
```

For legacy/custom names:

```bash
pnpm configure:env -- --domain <domain> --shop <shop-slug> --schema <db-schema>
```

Preview first when uncertain:

```bash
pnpm configure:env -- --domain <domain> --shop <shop-slug> --schema <db-schema> --print
```

## Full Setup Phases

1. Copy template into a lowercase-kebab shop folder.
2. Generate backend/storefront env files with `pnpm configure:env`.
3. Create or verify the Postgres schema.
4. Publish backend/storefront repos if needed.
5. Create/find Coolify project/app.
6. Sync backend env to Coolify without deleting unknown remote vars.
7. Configure Hostinger DNS:
   - root / `@` for storefront hosting
   - `www` for storefront hosting
   - `admin` `A` record to `62.72.35.11`
8. Create/find Hostinger website for the storefront domain.
9. Deploy backend and verify `/health`.
10. Build/upload storefront and verify the domain loads.

## Future Manifest Design

Prefer this shape when implementing automation:

```yaml
shop: marva
domain: marvahome.com
admin_host: admin.marvahome.com
db_schema: szalonirda
backend_repo: Webu-PRO/marva-backend
storefront_repo: Webu-PRO/marva-storefront
coolify_project: marva
coolify_app: marva-backend
hostinger_order_id: 12345
run_blog_seed: true
```

Target command:

```bash
pnpm shop:setup -- shops/marvahome.yaml
```

Keep the command phaseable:

```bash
pnpm shop:env -- shops/marvahome.yaml
pnpm shop:coolify -- shops/marvahome.yaml
pnpm shop:dns -- shops/marvahome.yaml
pnpm shop:hosting -- shops/marvahome.yaml
pnpm shop:verify -- shops/marvahome.yaml
```

## Tool Routing

Load these skills as needed:

- `coolify` for Coolify app/env/deploy operations.
- `hosting` for Hostinger website creation and domain verification.
- `dns` for Hostinger DNS zone changes.
- `myvps` for creating/verifying Postgres schemas on the VPS DB.
- `gh-submodule-publish` for GitHub deploy repo setup.
- `new-user` for the first Medusa admin.
- `new-admin-via-api` for later admins.

## Verification

Minimum proof for env-only work:

```bash
node --check scripts/configure-shop-env.mjs
pnpm configure:env -- --domain <domain> --shop <shop-slug> --schema <db-schema> --print
```

Check output includes:

- `SERVICE_URL_MEDUSA=https://admin.<domain>`
- `MEDUSA_DB_SCHEMA=<db-schema>`
- `STORE_CORS` includes storefront domain and `www`
- `ADMIN_CORS` includes admin domain
- `AUTH_CORS` includes admin and storefront domains
- `VITE_MEDUSA_BACKEND_URL=https://admin.<domain>`

Full setup stop condition:

- local env files exist
- DB schema exists
- Coolify app has matching backend env
- DNS has `admin` pointing to the VPS
- Hostinger website exists
- backend `/health` works
- storefront loads
