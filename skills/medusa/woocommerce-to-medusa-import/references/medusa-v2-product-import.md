# Medusa v2 Product Import Notes

Use this reference when implementing a WooCommerce to Medusa product importer.

## Safe importer shape

- `client.ts`: WooCommerce API pagination and auth only.
- `mapper.ts`: pure transforms from Woo payloads to Medusa product draft inputs.
- `import-woocommerce-products.ts`: Medusa container, existing-record lookup, workflow execution, summary output.

Keep mapper tests independent from Medusa runtime.

## WooCommerce fetch

Use basic auth over HTTPS or query auth only if the store requires it. Do not print request URLs when keys are in query params.

Pagination rules:

- `per_page=100`
- increment `page` until an empty response or fewer than `per_page`
- respect `--limit`
- retry 429/5xx with bounded backoff

Useful endpoints:

- `/wp-json/wc/v3/products`
- `/wp-json/wc/v3/products/<id>/variations`
- `/wp-json/wc/v3/products/categories`

## Existing Medusa lookup

Query existing products before writes:

- fields: `id`, `handle`, `metadata`, `variants.id`, `variants.sku`, `variants.metadata`
- match by `metadata.woo_id`
- fallback by `handle`
- variants match by `sku`, then `metadata.woo_variation_id`

## Dry-run output

Dry-run must show counts and sample identifiers without secrets:

```text
Woo products read: 100
Medusa create: 82
Medusa update: 12
Skip unchanged: 6
Variants create: 190
Variants update: 30
Images linked: 250
Currency: eur
Dry run: true
```

## Common hazards

- Woo descriptions are HTML. Strip or sanitize before assigning text fields.
- Woo variable products may require per-product variation fetches.
- Woo attributes can be global or custom; normalize names consistently.
- Woo prices may be strings. Parse as decimal numbers and reject invalid values.
- Duplicate SKUs must stop the import unless user explicitly allows generated fallback SKUs.
- Missing target currency should stop live import.
- Do not import draft/private Woo products as published by default.
