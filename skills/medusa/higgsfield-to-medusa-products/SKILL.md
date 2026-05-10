---
name: higgsfield-to-medusa-products
description: >-
  End-to-end product imagery pipeline for Medusa v2 shops. Generates product
  shots via Higgsfield (`higgsfield product-photoshoot create`), uploads them to
  the shop's S3 bucket on a public-read prefix, then patches the matching
  Medusa products via `POST /admin/products/{id}` to set thumbnail + images.
  Use when user says "generate product images", "refresh product photos",
  "shop képeket generálni", "Higgsfield images to Medusa", or supplies a list
  of product slugs/IDs and prompts. Reads backend URL + secret + AWS creds from
  a per-shop config file (or a future recodee bouncer MCP), never hardcodes
  them. Idempotent — re-running overwrites the same S3 keys + product fields.
argument-hint: <shop> [<manifest.json>]
allowed-tools: Bash(aws:*), Bash(curl:*), Bash(higgsfield:*), Bash(jq:*)
---

# Higgsfield → Medusa Product Images

One-shot pipeline that generates product shots with Higgsfield, hosts them on
the shop's S3 bucket, and updates Medusa products. Replaces the manual
sequence of `higgsfield product-photoshoot create` → `aws s3 cp` →
`curl -X POST /admin/products/{id}` that became the prototype while shipping
compastor.hu.

Pairs with `provision-medusa-s3-bucket` (which sets up the bucket + public-read
policy on `<prefix>products/*`) and lives downstream of
`higgsfield-product-photoshoot` (which owns prompt enhancement and CLI usage).

## When to use

User says any of:
- "generate product images for `<shop>`"
- "refresh `<shop>` product photos"
- "képeket generálni a `<shop>` termékekhez"
- supplies a manifest of product slugs/IDs + prompts and wants them on a Medusa shop

## Inputs

### Required: a shop name

`<shop>` is a short slug, e.g. `compastor`, `lifted`, `munchi`. The skill uses
it to:
- locate the per-shop env file: `~/.config/medusa-image-pipeline/<shop>.env`
- key the future bouncer-MCP scope: `mcp__recodee__vault_get_secret(scope="<shop>")`

### Required: a manifest

Either pass `<manifest.json>` as second arg, or place it at
`~/.config/medusa-image-pipeline/<shop>.manifest.json`. Schema in
`assets/manifest.example.json`. Each entry:

```jsonc
{
  "slug": "compastor-komposztolto",
  "product_id": "prod_01KR6T96D1JDVAVHN6CWR9AHVK",   // optional — looked up from slug if omitted
  "shots": [
    { "variant": "hero",      "mode": "product_shot",     "prompt": "neutral studio shot, single product front-facing, soft daylight" },
    { "variant": "lifestyle", "mode": "lifestyle_scene",  "prompt": "garden compost bin in use, autumn light, hands adding leaves" }
  ]
}
```

`variant` is free-form but `hero` + `lifestyle` is the convention (the first
becomes `thumbnail`, all of them become `images[]`).

### Required: env file (or vault — see Secret resolution)

`~/.config/medusa-image-pipeline/<shop>.env`:

```sh
# Per-shop config — gitignored, chmod 600
MEDUSA_BACKEND_URL="https://admin.compastor.hu"
MEDUSA_SECRET_KEY="sk_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

S3_BUCKET="compastor-medusa"
S3_REGION="eu-central-1"
S3_PREFIX="medusa/products/"
S3_PUBLIC_BASE="https://compastor-medusa.s3.eu-central-1.amazonaws.com/medusa/products"

AWS_ACCESS_KEY_ID="AKIA..."
AWS_SECRET_ACCESS_KEY="..."
```

Bootstrap once per shop:

```sh
mkdir -p ~/.config/medusa-image-pipeline
chmod 700 ~/.config/medusa-image-pipeline
$EDITOR ~/.config/medusa-image-pipeline/compastor.env
chmod 600 ~/.config/medusa-image-pipeline/compastor.env
```

## Secret + operation resolution

Two execution modes — pick by who's running the skill.

### Mode A: Agent-driven (Claude / Codex with `secret-mcp` registered)

For providers that already have bouncer-MCP wrappers, the agent calls the
bouncer tool directly — the secret never enters context. As of 2026-05-10
**only Higgsfield is wrapped** (recodee `tools/secret-mcp/`, landed in PRs
#1653 + #1655 + #1656; Phase 1 of the `agent-secret-vault-mcp` openspec
change).

Available bouncer tools right now:

```
mcp__secret-mcp__higgsfield_submit_generation({model, prompt, mode?, ...})
  -> {job_id, status}
mcp__secret-mcp__higgsfield_get_job({job_id})
  -> {id, status, result_url?, thumbnail_url?, error?}
```

Higgsfield workspace token is held in Infisical and read by the MCP at call
time. There is **no** `vault.get(name)` operation by spec design — vault
introspection is forbidden (`design.md` §"No introspection tools"). The
agent cannot fetch the secret value; it can only invoke wrapped operations.

Bootstrap once per developer:

1. Get the per-developer Infisical service-account token via the vault
   dashboard UI (recodee PR #1656).
2. Save it: `install -m 600 /dev/stdin ~/.config/recodee/infisical-token` then
   paste the token + Enter + Ctrl-D.
3. Make sure recodee `.mcp.json` is in the agent's MCP search path (it is by
   default when the agent runs in the recodee repo).

Agent-driven flow for the Higgsfield part of this pipeline:

```
job = mcp__secret-mcp__higgsfield_submit_generation(
  model="gpt_image_2", prompt=manifest_shot.prompt, ...)
while True:
  s = mcp__secret-mcp__higgsfield_get_job(job_id=job["job_id"])
  if s["status"] in ("succeeded", "failed"): break
# s["result_url"]  → curl download → aws s3 cp → POST /admin/products/{id}
```

For **AWS-S3 + Medusa-admin-API** (not yet bouncer-wrapped — Phase 2 of the
migration plan), the agent falls through to Mode B's env-resolution. Same
applies to Coolify, Hostinger, GitHub.

### Mode B: Shell-driven (`run-pipeline.sh`)

The bash script cannot call MCP tools; the bouncer MCP is agent-only by
design. Shell flows resolve secrets the traditional way, in order, first hit
wins:

1. **Process env vars** (`MEDUSA_BACKEND_URL`, `MEDUSA_SECRET_KEY`,
   `HIGGSFIELD_*`, `AWS_*`, …).
2. **Per-shop env file**: `~/.config/medusa-image-pipeline/<shop>.env`.

The resolver is `scripts/load-env.sh`. Higgsfield in Mode B uses the
`higgsfield` CLI (which holds its own auth via `higgsfield auth login`) —
this is the path for CI / cron / non-agent runs.

**Never** echo secret values, **never** put them in git, **never** ask the
user to paste them into chat.

## What the pipeline does

For each manifest entry, in order:

1. **Generate** — calls
   `higgsfield product-photoshoot create --mode <mode> --prompt "<prompt>" --count 1 --aspect_ratio <hint> --resolution 2k`
   for each `shot`. Polls until the job completes. Captures the resulting
   image URL on Higgsfield CDN. (Owned by the `higgsfield-product-photoshoot`
   skill — this skill does not write prompts.)

2. **Download** — `curl -fL` the Higgsfield CDN URL into a per-run cache:
   `~/.cache/medusa-image-pipeline/<shop>/<run-id>/<slug>-<variant>.png`.

3. **Optimize** (optional, on by default) — converts to JPEG via
   `magick convert <png> -quality 86 -strip <jpg>` if `magick`/`convert` is
   available. Skipped silently if not installed; PNGs upload as-is.

4. **Upload** — `aws s3 cp` to
   `s3://<S3_BUCKET>/<S3_PREFIX><slug>-<variant>.<ext>` with
   `--content-type image/jpeg` (or png) and a long `Cache-Control` header
   (`public, max-age=31536000, immutable`). Verifies HTTP 200 on the public
   URL before continuing.

5. **Resolve product ID** — if `product_id` was omitted in the manifest,
   `GET /admin/products?handle=<slug>` and use the first result.

6. **Patch product** — `POST <MEDUSA_BACKEND_URL>/admin/products/<id>` with
   `{"thumbnail": "<first-shot-url>", "images": [{"url": "<each-shot-url>"}]}`.
   Authentication is HTTP Basic with the Medusa secret API key
   (`Authorization: Basic <base64(secret:)>`).

7. **Verify** — `GET <MEDUSA_BACKEND_URL>/store/products?handle=<slug>` (no
   auth) and confirm the new URLs appear on `thumbnail` and `images[].url`.

8. **Report** — print one line per product:
   `ok    compastor-komposztolto (prod_01KR…) — 2 images`
   or `err   compastor-komposztolto — generate failed at shot 1`.

The orchestration is in `scripts/run-pipeline.sh`. Read it before invoking;
override behavior via flags rather than editing the script.

## Usage

```bash
# Default — reads ~/.config/medusa-image-pipeline/<shop>.env
# and ~/.config/medusa-image-pipeline/<shop>.manifest.json
bash <skill>/scripts/run-pipeline.sh compastor

# Explicit manifest path
bash <skill>/scripts/run-pipeline.sh compastor ./custom-manifest.json

# Dry-run — generates + uploads but skips the product patch
DRY_RUN=1 bash <skill>/scripts/run-pipeline.sh compastor
```

## Idempotency

- S3 keys are deterministic (`<slug>-<variant>.<ext>`) — re-runs overwrite
  the same object. Old version is retained because the bucket has versioning
  on (`provision-medusa-s3-bucket` enables it).
- Product patches are unconditional — re-running with a new manifest replaces
  `thumbnail` + `images[]` wholesale. There is no merge with existing images;
  if you want to keep prior images, list them in the manifest as additional
  `shots` with a `url` field instead of a `prompt`.
- If a Higgsfield generation fails for one shot, the entry is skipped and the
  product is left untouched. Other entries in the manifest still run.

## Bootstrap (first time per workstation)

1. Higgsfield CLI:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/higgsfield-ai/cli/main/install.sh | sh
   higgsfield auth login    # interactive, the user runs this
   ```
2. AWS CLI authenticated for the target bucket. Either:
   - Set `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` in the `<shop>.env`, OR
   - Run `aws configure --profile <shop>` and add `AWS_PROFILE=<shop>` to the env file.
3. `jq` and `curl` on `$PATH`. (`magick` optional, only used if installed.)

## Pitfalls

- **Wrong region in `aws s3 cp`** — for AWS S3, `S3_REGION` must be the actual
  bucket region, not `auto`. The `medusa-config.ts` of compastor previously
  hardcoded `region: "auto"` which is R2-specific; the file provider 500'd
  on AWS until that was fixed (commit `e0d9700`). Same lesson here: don't
  copy the value blindly between providers.
- **CORS** — the bucket needs `https://admin.<shop>.hu` in `AllowedOrigins`
  if you ever upload via Medusa admin UI. `provision-medusa-s3-bucket` sets
  this; if you run the pipeline against a hand-rolled bucket, verify with
  `aws s3api get-bucket-cors --bucket <bucket>`.
- **Public-read prefix** — the bucket policy from `provision-medusa-s3-bucket`
  permits `s3:GetObject` only on `<prefix>products/*`. The pipeline uploads
  to that exact path. If you change `S3_PREFIX`, also update the bucket
  policy or the public URLs return 403.
- **Higgsfield CDN expiry** — the CDN URLs returned by `higgsfield
  product-photoshoot create` are not durable. Always run step 2–4 (download +
  upload) before step 6 (patch); never paste a `cdn.higgsfield.ai/...` URL
  directly into Medusa.
- **Secret rotation** — when the Medusa secret key is revoked (e.g. via
  `revoke-secret-key.sh` or admin UI), update `<shop>.env`. Rotation cadence
  is the user's call; the pipeline does not rotate keys.

## Verification

After a successful run:

```bash
# Public store API — no auth, confirms storefront sees the new images
curl -s "https://admin.<shop>.hu/store/products?handle=<slug>" \
  -H "x-publishable-api-key: <pub-key>" | jq '.products[0] | {handle, thumbnail, images: .images | map(.url)}'

# S3 public URL responds 200
curl -I "https://<bucket>.s3.<region>.amazonaws.com/<prefix><slug>-hero.jpg"
```

Expected: `HTTP/2 200`, `thumbnail` and `images[].url` point to the
`<bucket>.s3.<region>.amazonaws.com` host.

## What this skill does NOT do

- Does not provision the S3 bucket — use `provision-medusa-s3-bucket`.
- Does not create Medusa products — products must already exist (use
  `woocommerce-to-medusa-import` or the admin UI).
- Does not write Higgsfield prompts — the user supplies them in the manifest;
  prompt enhancement is owned by the `higgsfield-product-photoshoot` backend.
- Does not rotate or revoke Medusa secret keys — separate concern, separate
  scripts.
- Does not store secrets in repos or in the skill itself.
