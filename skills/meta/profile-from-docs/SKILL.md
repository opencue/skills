---
name: profile-from-docs
description: 'Use when the user says "create a cue profile for X", "wire X into cue", or "build a profile from these docs". Scaffolds an integration profile: profile.yaml, logo, skills, MCPs, and CLI recipes.'
tags: [meta, cue, profile, scaffolding, mcp, skills]
---

# Profile From Docs

Turn an upstream product's documentation repo into a complete cue profile:
the `profile.yaml`, a logo, a set of lint-clean skills, wired MCP servers, and
CLI recipes. This codifies the clone → map → build → verify loop.

## Use This Skill For

- Standing up a new integration profile (Strapi, Supabase, a new platform)
  from its official docs
- Making sure the profile actually loads, lints, and materializes before you
  hand it over

## Prerequisites

- Run from the `cue` repo root (the one with `profiles/`, `resources/skills/`,
  `resources/mcps/`)
- `git` for cloning the upstream docs
- `bun` to run the cue source (`bun src/index.ts ...`) and the linter
- Note: `resources/skills` and `resources/mcps` are git submodules; commits
  land there first, then the main repo bumps the pointers

## Step 1: Opensrc the docs

Clone the upstream docs into `/tmp` (read-only reference, never committed):

```bash
git clone --depth 1 <docs-repo-url> /tmp/<name>-docs
```

## Step 2: Map the docs to cue surfaces

Scan for the four things a profile needs. Grep the docs, do not guess.

| cue surface | Look for in the docs |
|---|---|
| **MCP servers** | grep the docs for "mcp" / "model context protocol"; capture exact URLs, transport, auth. Prefer official servers over community ones. |
| **CLI** | the install/scaffold command and the subcommand reference |
| **Skills** | top-level doc sections (CLI, APIs, plugins, deploy, config), one skill per cohesive area |
| **Logo** | `find . -iname '*logo*' \( -iname '*.png' -o -iname '*.svg' \)` |

## Step 3: Build the artifacts

### profile.yaml + logo

```bash
mkdir -p profiles/<name>
cp /tmp/<name>-docs/path/to/logo.png profiles/<name>/logo.png
```

Write `profiles/<name>/profile.yaml`: `name`, `icon`, `iconImage: logo.png`,
`description`, `inherits: core`, a `persona`, `skills.local`, `mcps`, and an
`env` block for any MCP placeholders. Validate fields against
`profiles/schema.json`.

### Skills

One skill per area under `resources/skills/skills/<name>/<skill>/SKILL.md`.
Each must satisfy the linter (see Step 4): `name`, a `description` with a
trigger phrase, `tags`, a `## Prerequisites` section if it uses a CLI, an
example, and no em dashes.

### MCP servers

Add each server to `resources/mcps/configs/claude.sanitized.json` under
`servers`. An unknown id throws `McpNotFound` at materialize time, so the id
in `profile.yaml` `mcps:` must match the registry key exactly.

```json
"<id>": { "type": "http", "url": "${SERVICE_URL}/mcp",
  "headers": { "Authorization": "Bearer ${SERVICE_TOKEN}" } }
```

`${VAR}` placeholders resolve from the profile's `env:` then the shell.
Declare every placeholder in `env:` (an empty default is fine) so
materialization never throws `UnresolvedEnvPlaceholder`.

### CLI recipes

Add install recipes to `resources/cli-recipes.json` (npm / brew / apt / etc.)
for any CLI the skills invoke.

## Step 4: Verify before claiming done

```bash
# every skill lints clean (0 errors); --fix auto-resolves em dashes
bun src/index.ts lint-skill resources/skills/skills/<name>/<skill>/SKILL.md

# profile loads and appears in the picker
bun src/index.ts list | grep <name>

# both MCPs materialize with env substitution (no throw)
bun -e 'import {loadProfile} from "./src/lib/profile-loader.ts";
import {materializeMcp} from "./src/lib/mcp-materializer.ts";
const p=await loadProfile("<name>");
console.log(Object.keys((await materializeMcp(p)).claude.mcpServers));'
```

## Step 5: Commit across the submodules

```bash
# 1. skills submodule — stage ONLY your paths, not others' in-flight work
git -C resources/skills add skills/<name>
git -C resources/skills commit -m "feat(skills): add <name> skills"
# 2. mcps submodule
git -C resources/mcps add configs/claude.sanitized.json
git -C resources/mcps commit -m "feat(mcps): register <name> servers"
# 3. main repo — profile + recipes + submodule pointer bumps
git add profiles/<name> resources/cli-recipes.json resources/skills resources/mcps
git commit -m "feat(profiles): add <name> profile"
```

## Example

> "opensrc https://github.com/strapi/documentation and build a Strapi profile
> with skills, MCPs, and CLIs."

Result: `profiles/strapi/` (logo + yaml wiring the `strapi-docs` and
`strapi-mcp` servers), six skills under `resources/skills/skills/strapi/`,
two server entries in `claude.sanitized.json`, and `create-strapi` + `strapi`
recipes, all lint-clean and materialize-verified.

## Rules

- Map from the real docs; never invent MCP URLs, CLI flags, or API shapes.
- Prefer official MCP servers over community forks.
- One skill per cohesive area; do not cram CLI + API + deploy into one file.
- Declare every `${VAR}` in the profile `env:` or materialization throws.
- Stage only your own paths in the submodules; leave unrelated changes alone.
- Not done until lint, load, and materialize all pass.

## Next Step

After verifying, feature the profile in `profiles/_featured.yaml`, or run
`description-optimizer` on any skill whose activation you want to tune.
