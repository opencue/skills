# Soul skills — vault-migration audit

Sources:
- recodee `openspec/changes/agent-secret-vault-mcp/` (proposal.md + design.md + specs/secret-management/spec.md)
- recodee implementation: `tools/secret-mcp/` (Phase 1 PoC — landed in PR #1655 on 2026-05-10)
- skill scan of `~/Documents/soul/skills/skills/` on 2026-05-10
- existing MCPs at `~/Documents/soul/mcps/mcps/`

State of `agent-secret-vault-mcp` change as of 2026-05-10 01:11 GMT+2:
- ✅ Phase 0 — proposal landed (PR #1653)
- ✅ Phase 1 — bouncer MCP PoC for Higgsfield landed (PR #1655)
- ✅ Vault dashboard CRUD UI landed (PR #1656)
- 🔧 Active worktree: `consolidate-vault-into-apis-rename-2026-05-10-01-53` — uncommitted UI consolidation (vault feature folding into apis feature; not relevant to bouncer behavior)
- ❌ Phase 2 — per-provider migration (AWS, Coolify, Hostinger, GitHub, Stripe, Supabase, Medusa-admin) — not yet started
- ❌ Phase 3 — `.env` sunset — not yet started

Two purposes for this artifact:
1. **Vault migration roadmap** — per-provider operation list, the input the bouncer-MCP Phase-2 PRs need.
2. **Public-git readiness** — redaction footprint per skill, the input the "publish soul" decision needs.

## 1. Audit table — credential-touching skills

Sorted by primary provider, then skill name. `phase` references the design.md Phase-2 ordering.

| skill | provider(s) | secrets | non-secret config | redaction footprint | phase |
|---|---|---|---|---|---|
| `medusa/woocommerce-to-medusa-import` | WooCommerce, Medusa-admin-API, AWS-S3 (optional) | `WOOCOMMERCE_CONSUMER_KEY+SECRET`, `MEDUSA_SECRET_KEY`, optionally AWS keys | shop URL, backend URL, currency, region | `~/.config/woocommerce-medusa-import/env` path, no shop refs in body | Medusa+WooCommerce |
| `medusa/provision-medusa-s3-bucket` | AWS-S3 | `AWS_ACCESS_KEY_ID+SECRET` | bucket name, region, prefix, CORS origins | **YES** — `compastor-medusa`, `compastor.hu` examples | S3 |
| `medusa/higgsfield-to-medusa-products` | Higgsfield, AWS-S3, Medusa-admin-API | `HIGGSFIELD_*`, `AWS_ACCESS_KEY_ID+SECRET`, `MEDUSA_SECRET_KEY` | shop slug, backend URL, bucket, prefix, public base URL | **YES** — heavy `compastor` refs in body + example manifest | Higgsfield + S3 + Medusa |
| `medusa/new-admin-via-api` | Medusa-admin-API | `MEDUSA_ADMIN_PASSWORD` (existing) or `MEDUSA_INVITE_TOKEN` | backend URL, email | **YES** — `admin.compastor.hu` examples | Medusa |
| `medusa/db-generate` | none directly (CLI wrapper) | — | module name | none | — (skip) |
| `medusa/db-migrate` | DB (Postgres/Supabase) — via `DATABASE_URL` | `DATABASE_URL` (contains password) | schema name | none | Supabase |
| `medusa/new-user` | none (local CLI `npx medusa user`) | — | email, password (taken from CLI args) | none | — (skip) |
| `medusa/gh-submodule-publish` | GitHub | `gh` CLI auth token (existing GH_TOKEN/PAT) | org slug, repo names | **YES** — `Webu-PRO` examples | GitHub (4) |
| `higgsfield/higgsfield-product-photoshoot` | Higgsfield | `HIGGSFIELD_*` (CLI auth) | mode, prompt, count, aspect ratio | none | Higgsfield (1, PoC) |
| `higgsfield/higgsfield-marketplace-cards` | Higgsfield | `HIGGSFIELD_*` | listing platform, product photo | none | Higgsfield (1) |
| `higgsfield/higgsfield-generate` | Higgsfield | `HIGGSFIELD_*` | model id, job set type, soul reference id | none | Higgsfield (1) |
| `higgsfield/higgsfield-soul-id` | Higgsfield | `HIGGSFIELD_*` | training images path | none | Higgsfield (1) |
| `coolify` | Coolify | `COOLIFY_API_TOKEN` (already in MCP) | server URL, app UUID, project name | none | Coolify (5) |
| `dns` | Hostinger | `HOSTINGER_API_TOKEN` | domain, record type, TTL | none | Hostinger (6) |
| `domains` | Hostinger | `HOSTINGER_API_TOKEN` | domain, TLD, WHOIS profile id | none | Hostinger (6) |
| `hosting` | Hostinger | `HOSTINGER_API_TOKEN` | order id, datacenter code, free subdomain prefix | none | Hostinger (6) |
| `vps` | Hostinger | `HOSTINGER_API_TOKEN` | VM id, hostname, project, SSH key, template id | none | Hostinger (6) |
| `myvps` | self-hosted Supabase VPS (SSH) | SSH private key (`SUPA_SCHEMA_SSH_TARGET`) | host, port, schema | none, but env var leaks IP | Supabase / Infra |
| `stripe-webhooks` | Stripe | `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET` | endpoint path, event types | none | Stripe (2) |
| `supabase` | Supabase | `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_URL` | project ref, schema, table names | none | Supabase (3) |
| `github` | GitHub | `gh` CLI auth (`GH_TOKEN`/PAT) | repo slug, issue/PR numbers | none | GitHub (4) |
| `keyword-research` | (optional) Ahrefs/Semrush | `AHREFS_API_KEY`, `SEMRUSH_API_KEY` (optional) | topic, market, language | none | (optional, off-track) |
| `flight-search` | LetsFG | `LETSFG_API_KEY` | airports, dates, cabin class | none | (out-of-scope) |
| `openai-docs` | none (read-only docs MCP) | — | doc anchors | none | — (skip) |
| `ask-claude` / `ask-gemini` | local CLI auth | local CLI session | prompt | none | (out-of-scope, local-only) |

**Total credential-touching:** ~18 skills (excluding pure-doc references and local-only CLIs).

## 2. Skipped — pure-reference skills (no secrets, keep out of vault scope)

`medusa-reference`, `building-with-medusa`, `building-storefronts`, `storefront-best-practices`, `building-admin-dashboard-customizations`, `creating-internal-agents` — these are docs-as-context. No HTTP calls. No vault role.

Plus most caveman/*, all design/UI skills, all orchestration/meta (autopilot, ralph, ulw, plan, …), Obsidian skills, code-review/security-review, doc/pdf/png-alpha-cleaner — utilities with zero outbound auth.

## 3. Provider-by-provider operation list (vault contract draft)

This is the input each Phase-2 PR needs. Each entry is a tool the bouncer MCP must expose, named per design.md as `mcp__secrets__<provider>__<operation>(args) -> result`.

### Higgsfield (Phase 1 — LANDED in PR #1655)

Tools live in recodee `tools/secret-mcp/secret_mcp/tools/higgsfield.py`.
Currently exposed:

- ✅ `mcp__secret-mcp__higgsfield_submit_generation({model, prompt, mode?, hook_id?, setting_id?, avatar_id?, aspect_ratio?, duration?, product_ids?}) -> {job_id, status}`
- ✅ `mcp__secret-mcp__higgsfield_get_job({job_id}) -> {id, status, result_url?, thumbnail_url?, error?}`

Token: `HIGGSFIELD_WORKSPACE_TOKEN` in Infisical, never returned to caller.

Not yet wrapped (proposed for follow-up Higgsfield PRs — these are NOT the
operations the existing 4 higgsfield/* CLI skills use; the CLI skills call
the Higgsfield CLI which holds its own auth, so they don't need bouncer
wrapping at all):

- `submit_product_photoshoot` — distinct backend prompt-enhancer endpoint;
  if added, would let agent skills bypass the CLI dependency.
- `submit_marketplace_card` — same rationale.
- `train_soul` — same rationale.

Migration call: the existing `higgsfield/*` skills are CLI-based (`higgsfield
auth login` + `higgsfield product-photoshoot create ...`). They do not need
bouncer wrapping unless the team wants to drop the CLI dependency. The
bouncer's two current tools cover the lower-level `/generate` + `/jobs/{id}`
HTTP API which is what `app/modules/ad_studio/higgsfield_client.py` uses
internally. Decide per-skill whether the CLI path or the bouncer path is
preferred; both are valid.

(Used by: 4 higgsfield/* skills via CLI; 1 medusa/higgsfield-to-medusa-products via either CLI or bouncer.)

### AWS-S3 (parallel, not in design.md ordering)

- `upload_object({bucket, key, body_b64, content_type, cache_control}) -> {etag, public_url}`
- `head_object({bucket, key}) -> {exists, size, etag}` (for idempotency checks)
- `put_bucket_policy({bucket, policy}) -> {ok}` (provision-only; admin scope)
- `put_bucket_cors({bucket, rules}) -> {ok}` (provision-only)
- `put_bucket_lifecycle({bucket, rules}) -> {ok}` (provision-only)

(Used by: provision-medusa-s3-bucket, higgsfield-to-medusa-products, woocommerce-to-medusa-import (image-copy mode).)

Note: payloads can be megabytes; consider a chunked upload tool variant or signed-URL pattern that gives the agent a presigned PUT URL (no token leak — the URL itself is short-lived and the agent uploads through it). Bouncer-MCP-friendly variant.

### Medusa-admin-API (per-shop scope, not in design.md ordering)

Scope is `<shop>` (compastor, lifted, …). Vault stores per-shop `MEDUSA_SECRET_KEY` and the backend URL.

- `list_products({scope, query?}) -> {products[]}`
- `get_product({scope, product_id_or_handle}) -> {product}`
- `patch_product({scope, product_id, body}) -> {product}`
- `upload_files({scope, files[]}) -> {uploaded[]}` (the broken `/admin/uploads` endpoint — Phase-2 scope)
- `list_api_keys({scope, type}) -> {api_keys[]}`
- `revoke_api_key({scope, id}) -> {ok}`
- `delete_api_key({scope, id}) -> {ok}`
- `invite_admin({scope, email}) -> {invite_token}`
- `accept_admin_invite({scope, token, password}) -> {admin_id}`

(Used by: 6 medusa/* skills.)

### Coolify (Phase 2 slot 5)

The existing `mcp__coolify__*` server already matches the bouncer shape (token held server-side, operation-per-tool). Migration: change token-loading from `.env` / settings file to Infisical at startup. The exposed tools are already the right shape. Specifically used:

- `mcp__coolify__list_applications`
- `mcp__coolify__get_application`
- `mcp__coolify__env_vars` (read)
- `mcp__coolify__bulk_env_update` (write)
- `mcp__coolify__deploy`
- `mcp__coolify__restart_project_apps`
- `mcp__coolify__application_logs`
- (full list in `~/.claude/agents/` MCP catalog)

Vault stores: `COOLIFY_API_TOKEN`, `COOLIFY_API_URL` (single — Coolify is one self-hosted instance).

### Hostinger (Phase 2 slot 6)

Four skills (dns, domains, hosting, vps). Each operation against `https://api.hostinger.com/v1/...` with a single bearer token. Tool surface ≈ a 1-to-1 mapping of every API endpoint these skills currently call. Recommend the PoC PR generates the tools from the OpenAPI spec rather than hand-writing.

Vault stores: `HOSTINGER_API_TOKEN` (single — one Hostinger account).

### Stripe (Phase 2 slot 2)

`stripe-webhooks` is the only skill — it builds verification handlers, not bouncer-callers, so it does NOT need bouncer wrapping for the secret-key path. The webhook *secret* is read by the running service, not the agent. **Drop from vault scope** — this is a doc skill that emits code into a target repo; the target repo handles its own secrets.

### Supabase (Phase 2 slot 3)

- `db_query({scope, sql, params})` — for `db-migrate` migrations and ad-hoc reads.
- `db_apply_migration({scope, sql_file})` — for `db-generate`/`db-migrate` flows.

Scope = `<shop>` again, since each shop has its own schema in self-hosted Supabase.

For SSH-tunnel access (`myvps` skill), wrap differently — bouncer holds the SSH key, executes the SQL, returns rows. No tunnel URL exposure.

### GitHub (Phase 2 slot 4)

Used by `github` and `gh-submodule-publish`. The `gh` CLI already holds its own auth (in `~/.config/gh/`). Two paths:

- **Status quo**: keep `gh` CLI as-is. It does not return the token; agent only sees command results. Effectively already a "soft bouncer" (token never enters context).
- **Vault path**: bouncer wraps `gh` operations and reads PAT from Infisical. Cleaner for the no-leak invariant but adds a layer.

Recommend: keep `gh` CLI as-is for Phase 2; add bouncer wrapping only if the team standardises away from `gh auth`.

## 4. Cross-reference vs design.md — deltas

design.md enumerates Higgsfield, Stripe, GitHub examples and a Phase-2 ordering. The audit surfaces these gaps:

| Gap | What design.md says | What the audit shows | Suggested resolution |
|---|---|---|---|
| **AWS-S3** missing from Phase-2 list | Not enumerated | 3 skills hit S3 directly | Add S3 as Phase-2 entry, parallel to Higgsfield (independent provider). |
| **Medusa-admin-API** missing | Not enumerated; `provider_credentials` cited as out-of-scope | 6 skills hit it; the secret is per-shop, not per-provider. Per-shop scoping ≠ what design.md envisions (per-environment dev/staging/prod). | Extend scope semantics: in addition to environment scopes, support a free-form scope dimension (e.g. `shop=compastor`) so the bouncer can hold many `MEDUSA_SECRET_KEY`s side-by-side. |
| **WooCommerce** not enumerated | — | `woocommerce-to-medusa-import` calls Woo store APIs with consumer key+secret per source store | Add per-source-store scope. |
| **Stripe webhook secret** included in design.md ordering | Phase-2 slot 2 | Audit shows `stripe-webhooks` is a code-generator skill, not a bouncer caller. The secret is consumed by the *target* service, not the agent. | Drop from bouncer scope; revisit when an agent actually needs to call Stripe API on behalf of a tenant. |
| **`mcp__secrets__` namespace vs existing `mcp__coolify__`** | Spec uses `mcp__secrets__<provider>__<op>` | Existing wrappers (`coolify`, `hostinger-api`) use bare provider namespaces | Decide: rename existing to `mcp__secrets__coolify__*` to match spec, OR loosen the spec to accept any namespace as long as the no-leak invariants hold. **Recommend the latter** — renaming breaks every project that uses the existing servers. |

## 5. Coolify pilot — vault-native skill template

Recommended pilot (advisor agreed). Reasons: (a) existing MCP already bouncer-shaped, (b) the compastor `R2_REGION` follow-up needs a Coolify env-var update — pilot work doubles as production work, (c) it validates the contract on a second provider before commit (Higgsfield is Phase-1 PoC).

### Pilot skill: `medusa/coolify-set-env`

```
Goal: Atomically set or unset env vars on a Coolify-hosted Medusa backend
      (or any Coolify app) and trigger a redeploy.
Input: <shop>, key=value pairs, --no-redeploy flag
Vault: holds COOLIFY_API_TOKEN, COOLIFY_API_URL (one Coolify, one team)
Bouncer ops used:
  - mcp__coolify__list_applications  (lookup: shop slug → app uuid)
  - mcp__coolify__env_vars           (read current state for diff)
  - mcp__coolify__bulk_env_update    (apply changes)
  - mcp__coolify__deploy             (trigger redeploy unless --no-redeploy)
  - mcp__coolify__deployment         (poll until done)
Reports: diff applied, redeploy id, final deploy status.
```

This is a 100-line bash-or-python skill. It is the "happy path" template for every other vault-native skill: take a scope arg, look up the right resource, call wrapped MCP ops, never see tokens.

### What this pilot validates

- The "scope" semantics — does the bouncer accept `scope=<shop>` or only environment scopes?
- The output filter — set an env var that contains the literal `COOLIFY_API_TOKEN` value as a poison; confirm the canary fires.
- The fail-closed mode — point `COOLIFY_API_URL` at `localhost:9` for one run; confirm the skill returns `vault_unreachable` from every op.

### What this pilot does NOT validate (for follow-up)

- Per-shop scoping for `Medusa-admin-API` (different scope shape).
- Streaming responses (Coolify deploy logs are line-streamed; design.md does not specify how the bouncer surfaces streams).
- Large-payload upload (S3 image bytes — relevant for the higgsfield→medusa pipeline but not Coolify).

## 6. Roll-up

**Migration sizing:**

| Provider bucket | Skills affected | Estimated PR effort |
|---|---|---|
| Higgsfield (Phase 1) | 5 | already planned |
| AWS-S3 | 3 | medium — chunk-upload design needed |
| Medusa-admin-API | 6 | medium — per-shop scope dimension |
| Coolify | 1 (pilot) + every shop deploy | small — existing MCP, just swap token loader |
| Hostinger | 4 | medium — many endpoints, OpenAPI-driven generation |
| Supabase | 1 | small |
| GitHub | 2 | tiny — keep `gh` CLI as soft-bouncer |
| Stripe | 0 | drop from scope |
| WooCommerce | 1 | small — per-source-store scope |

**Public-git readiness (separate from vault — answers "is it worth publishing soul"):**

Skills with shop-specific refs that need redaction before publication:
- `medusa/provision-medusa-s3-bucket` — `compastor-medusa` examples
- `medusa/higgsfield-to-medusa-products` — heavy compastor refs
- `medusa/new-admin-via-api` — `admin.compastor.hu` examples
- `medusa/gh-submodule-publish` — `Webu-PRO` org refs

All others are clean. Two-tier publication is feasible:
- **Public**: 14 generic skills + the 4 redacted ones (replace `compastor` → `<shop>`, `Webu-PRO` → `<your-org>`).
- **Private**: the unredacted versions stay in the user's own `soul/` mirror.

## Next actions

1. **Rotate the AWS access key** (`AKIAQ7MTFG2KU5XUGF67` — already exposed in session memory `4178`). Blocks public publication and is good hygiene regardless.
2. **Land the Higgsfield Phase-1 PoC PR** in recodee (out of scope for this artifact — that's the recodee team).
3. **Decide on scope-dimension extension** (per-shop, per-source-store) before any Phase-2 PR.
4. **Pilot: build `coolify-set-env`** as the second vault-native template (parallel to Higgsfield PoC), use it for the compastor `R2_REGION` follow-up.
5. **Hold off on rewriting existing skills** until Phase 1 lands. New skills today should keep the `load-env.sh` placeholder pattern that gracefully prefers the bouncer when present (`higgsfield-to-medusa-products` is the reference).
