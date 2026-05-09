---
name: woocommerce-to-medusa-import
description: Build or run WooCommerce product importers into Medusa v2 backends. Use when importing WooCommerce products, variations, categories, images, prices, inventory, or metadata into Medusa, especially repos with apps/backend. Includes safe secret handling, dry-run/idempotent import rules, Medusa workflow usage, and verification steps.
---

# WooCommerce to Medusa Import

Use this skill when a user wants WooCommerce products pushed into a Medusa backend.

## First decisions

1. Inspect the repo backend package and Medusa version.
2. Prefer a backend `medusa exec` script for batch imports.
3. Keep credentials outside repos and chat.
4. Use Medusa workflows for product mutations. Do not write product rows directly.
5. Make the importer idempotent before any live write.

## Secret handling

Never ask the user to paste WooCommerce secrets into chat.
Never commit secrets, generated `.env` files, or credential screenshots.

Support this resolution order:

1. Process env vars:
   - `WOOCOMMERCE_URL`
   - `WOOCOMMERCE_CONSUMER_KEY`
   - `WOOCOMMERCE_CONSUMER_SECRET`
2. Global local env file, outside repos:
   - `~/.config/woocommerce-medusa-import/env`
3. Repo-local env only if the repo already has an untracked local env pattern.

Recommended global env file:

```sh
mkdir -p ~/.config/woocommerce-medusa-import
chmod 700 ~/.config/woocommerce-medusa-import
cat > ~/.config/woocommerce-medusa-import/env <<'ENV'
WOOCOMMERCE_URL="https://example.com"
WOOCOMMERCE_CONSUMER_KEY="ck_replace_me"
WOOCOMMERCE_CONSUMER_SECRET="cs_replace_me"
ENV
chmod 600 ~/.config/woocommerce-medusa-import/env
```

When running imports, source without echoing values:

```sh
set -a
. ~/.config/woocommerce-medusa-import/env
set +a
pnpm medusa exec ./src/scripts/import-woocommerce-products.ts -- --dry-run
```

If commands may be logged, do not inline secret values in the command.

## Import contract

Build importers with these flags:

- `--dry-run`: default true unless user explicitly requests live write.
- `--limit <n>`: cap products for test runs.
- `--page <n>` or `--since <iso>`: resume/scope pulls.
- `--force-update`: allow overwriting existing Medusa fields.
- `--include-drafts`: include Woo draft/private products only when requested.

Idempotency keys:

- Product: `metadata.woo_id`, fallback `handle`.
- Variant: `sku`, fallback `metadata.woo_variation_id`.
- Category: normalized slug/handle.
- Image: URL.

Store Woo source fields in metadata:

- `woo_id`
- `woo_permalink`
- `woo_date_modified_gmt`
- `woo_status`
- `woo_type`

## Mapping rules

Product:

- `name` -> `title`
- `slug` -> `handle`
- `short_description` or stripped `description` -> `subtitle`
- stripped `description` -> `description`
- `status === "publish"` -> `published`, otherwise `draft`
- `images[].src` -> Medusa product images
- first image -> `thumbnail`

Categories:

- Woo categories map by slug/name to Medusa product categories.
- Create missing categories only when requested or when importer owns taxonomy setup.
- Prefer explicit mapping file for messy stores.

Variants:

- Woo variable product variations become Medusa variants.
- Woo simple product becomes one default variant.
- Attribute names become Medusa option titles.
- Attribute values become option values.
- `sku` must be preserved.
- If SKU is missing, generate a stable fallback from product/variation ID and record it in metadata.

Prices:

- Medusa v2 prices are stored as decimal amounts. Do not multiply by 100.
- Pick currency from target Medusa region/store config or an explicit `--currency` flag.
- Use sale price only if the user asks to import sale prices as active prices.

Inventory:

- Default `manage_inventory: false` unless the project has inventory/location mapping.
- If importing inventory, map stock location first and verify reservations behavior.

Images:

- First pass may reference Woo image URLs directly.
- Upload/copy into Medusa file provider only if requested or if Woo URLs are not durable.

## Medusa v2 implementation rules

- Use `medusa exec` scripts for batch ETL.
- Use `createProductsWorkflow`, product update workflows, sales-channel linking workflows, and variant-image workflows where available.
- Query existing products with `query.graph()`.
- Do not put import business logic in API routes.
- Do not call module services directly from routes for mutations.
- Keep mapper functions pure and unit-test them.

Load repo-specific Medusa backend guidance when present. If the `building-with-medusa` skill is available, load it before editing backend code.

## Files to create in a repo

Typical minimal implementation:

- `apps/backend/src/scripts/import-woocommerce-products.ts`
- `apps/backend/src/scripts/woocommerce/mapper.ts`
- `apps/backend/src/scripts/woocommerce/client.ts`
- `apps/backend/src/scripts/woocommerce/__tests__/mapper.spec.ts`

Use `assets/import-woocommerce-products.template.ts` as a starting point only. Adapt imports and workflow names to the installed Medusa version.

## Verification

Run in order:

1. Mapper unit tests.
2. Backend build/typecheck.
3. Dry-run with `--limit 3`.
4. Live import only after dry-run summary is reviewed or user explicitly requested live import.
5. Query Medusa products and verify no duplicate handles/SKUs.

Report:

- product count read from Woo
- products to create/update/skip
- variants to create/update/skip
- category behavior
- image behavior
- verification commands/results
- secret handling path used, without values
