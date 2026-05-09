---
name: skill-suggestion
description: >-
  Load PROACTIVELY when you observe the user about to repeat an automatable
  workflow — e.g. they just ran the same 3+ step sequence twice, manually
  walked through something an existing skill could do, or solved a problem
  that warrants a reusable skill. Suggests installing an upstream skill OR
  scaffolding a new one. NOT for reactive "find me a skill for X" requests
  (use `find-skills`). NOT for one-off operations.
---

# skill-suggestion

You are PROACTIVE. The user doesn't ask for this skill — you load it when you spot a pattern they should automate. Then you make ONE concise suggestion and stop.

## When to load this skill

Load when ANY of these is true:

- **Repetition observed.** The user has just performed the same multi-step workflow ≥2 times in this session, or you're about to do it for the 2nd time.
- **Skill mismatch.** You manually executed something an existing skill (visible in your skills list) could have handled in one call.
- **Reusable pattern emerged.** A non-trivial workflow just succeeded and the user is likely to want it again (e.g. a deploy sequence, a debug recipe, a setup procedure).
- **The user explicitly says** "should this be a skill", "automate this", "next time", "I keep doing X", or "/skill-suggestion".

## When NOT to load

- The user is asking a one-off question (just answer it).
- The task is a single tool call (no automation value).
- You already suggested a skill this session for the same pattern (don't nag).
- The user explicitly waved off a prior suggestion.
- The pattern is highly user-specific and lives better as a Justfile recipe than a skill — suggest the recipe instead.

## What to do once loaded

### Step 1 — Identify the pattern in one sentence

Write down the workflow you observed, like:
- "User ran `pnpm install && pnpm build && rsync ...` to deploy storefront — 2nd time this session."
- "User manually walked through 4 SQL inserts to seed Medusa products."
- "User asked DNS-related questions; spent 3 turns navigating Hostinger UI."

If you can't compress it to one sentence, you don't have a clear pattern — abort.

### Step 2 — Search for an existing skill

**Use the local catalog first — it's pre-indexed and zero-latency.**

```bash
# Catalog file: ~/Documents/soul/skills/catalog/catalog.json
# Refreshed via: just refresh-catalog
# Quick search across installed + upstream + mcps:
just catalog-search <keyword>
```

If the catalog is stale (`generated_at` more than ~24h old per `just catalog-stats`), refresh it first: `just refresh-catalog`. The refresh hits GitHub for `anthropics/skills`, `obra/superpowers`, `wshobson/agents`, and any other repos in `soul/skills/catalog/known_repos.json`.

Search order within the catalog:

1. **`installed`** — already loaded into Claude Code / Codex. If matched, the user just needs to invoke (or YOU should have invoked it). Surface the existing skill name + trigger phrase.
2. **`upstream`** — exists in a trusted repo but not adopted yet. Surface the name + repo URL; offer to adopt via `soul`.
3. **`mcps`** — sometimes the right answer is an MCP server, not a skill (stateful APIs, persistent connections).
4. **Wider GitHub** — only if catalog has no match: `gh search code 'filename:SKILL.md <keyword>'`. If the result is from a publisher you trust, suggest adding the repo to `known_repos.json` so future searches see it.

### Step 3 — Decide which path

| Finding | Action |
|---------|--------|
| Existing skill, already loaded | "FYI — `<name>` skill handles this; next time say <trigger phrase>." |
| Existing skill in `soul/`, not synced | "Found `<name>` in soul/, run `~/Documents/soul/skills/scripts/install-local.sh` to activate." |
| Upstream skill exists | Show the URL + one-line summary. Ask if they want to adopt via `soul` skill (which knows the upstream-first rule). |
| Nothing exists | Offer to scaffold via `soul`. Sketch the proposed `name`, `category`, `description` triggers. Ask before writing. |
| Better as Justfile recipe | Suggest adding to `~/Documents/Justfile` instead. Skills are for *behavior*; Justfile is for *commands*. |

### Step 4 — Format the suggestion

Keep it ≤4 lines. Pattern:

```
💡 Suggestion: This looks repeatable. <Found-X | Should-create-Y>.
   • <one-line action> (e.g. "say `/<name>` next time" or "I can scaffold `meta/<name>` — confirm?")
   • <opt-out phrase> (e.g. "or 'skip' to ignore")
```

Then **stop**. Don't argue, don't elaborate. The user will either accept, ignore, or wave you off.

## Anti-nag rules

- **One suggestion per pattern per session.** If the user ignored it, don't bring it up again until next session.
- **Don't suggest during interrupts.** If the user is mid-task and the suggestion isn't blocking, defer to end-of-task.
- **Don't suggest the trivial.** A 1-line bash command isn't a skill candidate. A 1-line Justfile recipe might be.
- **Skill > Justfile recipe** when the operation needs LLM reasoning (parse output, decide branch). **Justfile > skill** when it's pure deterministic command sequence.
- **Skill > MCP** for prompts/workflows. **MCP > skill** for stateful tool surfaces (databases, APIs, persistent connections).

## When the user says "yes, scaffold it"

Hand off to the `soul` skill. Don't write SKILL.md files yourself — `soul` knows the canonical paths, frontmatter rules, and the upstream-first procedure.

## When the user says "yes, install upstream"

For Anthropic's `anthropics/skills` repo or community catalogs:

1. `git clone <repo> /tmp/<name>-source`
2. `cp -r /tmp/<name>-source/<skill-path> ~/Documents/soul/skills/skills/<category>/<name>/`
3. Add `Source: <upstream URL>@<commit-sha>` line at the top of the body
4. Trigger sync: `~/Documents/soul/skills/scripts/install-local.sh`

Use the `soul` skill's procedure — it documents the canonical layout.

## Calibration — when in doubt, don't suggest

False positives erode the user's trust in the suggestion. Skip the suggestion if:

- You're <70% sure the pattern is repeatable
- The user's intent is unclear
- The "automation" would replace a step the user wants to retain manual control over (e.g. destructive operations)

Better to miss a suggestion than fire a bad one.

## Sister tooling

- **`find-skills`** — REACTIVE counterpart. User-initiated lookups. Don't compete; defer to it when the user explicitly asks.
- **`soul`** — scaffolds the new skill once the user agrees.
- **`workspace-recipes`** — alternative target when the answer is a Justfile recipe, not a full skill.
- **`note --priority`** — if the user wants to remember a workflow but isn't ready to skill-ify it yet.
