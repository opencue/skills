---
name: smart-loader
description: >-
  Use when the user mentions a tool, platform, or workflow (coolify, resend,
  hostinger, medusa, gh, sanity, etc.) and no currently loaded skill covers
  it. Also use when the user says "smart load", "load that skill", "find a
  skill for X", or "is there a skill for X". Locates the matching SKILL.md
  on disk and follows it inline, since Claude Code's loadable skill list is
  frozen at session start by the active cue profile.
tags: [meta, cue, routing]
category: meta
version: 1.0.0
requires_mcps: []
allowed-tools: Bash(jq:*), Bash(grep:*), Bash(awk:*), Bash(find:*), Bash(head:*), Read
triggers:
  - "smart load"
  - "load that skill"
  - "find a skill for"
  - "is there a skill for"
  - "deploy to coolify"
  - "ssh to vps"
  - "use when topic mentions a tool, platform, or workflow not in active profile"
---

# smart-loader

## Prerequisites

- `jq` (`apt install jq` / `brew install jq`) for the fast-path catalog lookup. The filesystem-scan fallback only needs `grep` and `awk`, which are POSIX baseline.

Claude Code's loadable skill list is frozen at session start by the active cue profile. This skill is the workaround: when the user's topic matches a skill that isn't loaded, this skill locates its SKILL.md on disk, reads it as a regular file, and follows its instructions inline.

It is the fallback. Skills already loaded via `Skill()` always take priority.

## Iron contract

1. **Loaded skills win.** Before invoking smart-loader, scan the available-skills list. If a loaded skill's description matches, use `Skill()` and stop.
2. **One match per topic per session.** Don't repeatedly re-load the same skill. Once you've followed its body once, it stays applied for the topic.
3. **No fabrication.** Only follow a SKILL.md you actually read from disk this session. If the lookup returns nothing, say so plainly. Don't paraphrase what you imagine the skill says.
4. **Honest framing.** When you apply a smart-loaded skill, tell the user: "I'm following `meta/smart-loader` to apply the `<name>` skill (not loaded in profile `<profile>`)." That way they know it's a soft application, not a real `Skill()` invocation.
5. **Hard switches stay manual.** If the skill's body needs an MCP that isn't connected, or relies on slash-command wiring, stop and tell the user to `cue use <profile>` and restart. Don't fake what you can't deliver.
6. **Verify before you recommend by name.** Before mentioning any skill by name in a response (whether to use it, suggest it, or describe it), run `smart-lookup.sh <name>` to confirm the SKILL.md exists on disk on *this* machine. Project AGENTS.md and CLAUDE.md files often reference skills at paths that have since moved (e.g. `soul/` → `cue/resources/skills/`), been renamed, or never been installed locally. If the lookup returns nothing, say "no skill named X exists here" instead of recommending a phantom. If it returns a different path than what AGENTS.md claims, use the path the lookup gave you.

### How to refresh the index when it lies

If the lookup returns no hits but you have reason to think the skill should exist (recent addition, the user references it confidently), rebuild the catalog before giving up:

```bash
bash ~/Documents/cue/resources/skills/scripts/rebuild-catalog-local.sh
bash ~/Documents/cue/resources/skills/skills/meta/smart-loader/scripts/smart-lookup.sh <keyword>
```

The rebuild scans the current cue tree and rewrites `catalog.json` with live paths. Use it once per session at most.

## When to load this skill

Load smart-loader proactively when **all three** hold:

- The user's prompt mentions a specific tool, platform, vendor, or named workflow (coolify, resend, hostinger DNS, medusa db:migrate, claude-api caching, sanity GROQ, etc.).
- No skill in your available-skills list covers that topic.
- The user is asking you to *do* something with it, not just discuss it abstractly.

Don't load smart-loader when:

- A loaded skill already covers the topic (use `Skill()` directly).
- The request is conversational, exploratory, or doesn't need a playbook.
- You already smart-loaded a skill for this topic earlier in the session.
- The user explicitly said "answer without skills."

## The lookup recipe

### Step 1, Run the lookup

```bash
bash ~/Documents/cue/resources/skills/skills/meta/smart-loader/scripts/smart-lookup.sh <keyword>
```

Replace `<keyword>` with the topic word (`coolify`, `resend`, `dns`, etc.). Output is tab-separated, ranked by match score, capped at top 5:

```
<category/name>  <absolute path>  <score>  <description>  <mcp_status>
```

What the script does automatically:
- Auto-rebuilds the catalog if any SKILL.md is newer than the index (throttled to once per 60s).
- Tries the indexed catalog first, then a live filesystem grep, then a fuzzy fallback via `difflib.get_close_matches` if both return zero hits. Fuzzy matches carry score 10 and are tagged `(fuzzy)` in the description.
- Drops rows whose source path is stale (catalog drift).

Score legend: 100 exact name, 80 name substring, 60 description match, 20 body match, 10 fuzzy.

Empty output means truly no match (no exact, no fuzzy, no body hit).

### Step 1b, Read the mcp_status column before recommending

The fifth column is critical. Values:

- **empty**, skill declares no MCP requirements. Safe to soft-load.
- **`ok`**, skill needs an MCP and it is loaded in the active profile. Safe to soft-load.
- **`missing:<mcp1>,<mcp2>`**, skill needs MCPs that are NOT currently loaded. **Do not soft-load.** Tell the user to switch to a profile that has those MCPs:

  > This skill needs MCP `<name>` which isn't loaded in your active profile `<active>`. Run `cue use <profile>` and restart Claude Code. The smart-loader skill cannot fake MCP tool calls.

  Use the `meta/profile-suggest` skill (or grep `~/Documents/cue/profiles/*/profile.yaml` for the MCP name) to suggest the right profile.

### Step 2, Read the chosen SKILL.md

If the lookup returned multiple candidates, pick the one whose `category/name` and description most directly match the topic. If two look equally relevant, list the top three with their one-line descriptions and ask the user which.

Use the `Read` tool with the absolute path from the lookup output. Read the whole file. Skills are designed to be self-contained playbooks.

### Step 3, Apply it

Tell the user once, plainly:

> Smart-loading `<category>/<name>` from disk (not in active profile `<active>`). Source: `<path>`.

Then follow the skill's instructions for the current task. If the skill's body invokes other skills via `Skill()` that aren't loaded, recurse into smart-loader for each, but only if the user's task actually needs them.

### Step 4, Stop when done

When the task that triggered the load is complete, drop the skill from your active reasoning. Don't carry its instructions forward into unrelated turns.

## Failure modes

| Symptom | Diagnosis | Action |
|---|---|---|
| Catalog grep returns nothing, filesystem scan returns nothing | No skill exists for that topic | Say so: "No skill covers X. Want me to scaffold one with `/skill-reviewer`?" |
| SKILL.md references MCP tools not in your tool list | The skill needs a profile that loads that MCP | Tell user: "This needs `cue use <profile>` to load MCP `<name>`." Stop, don't fake it. |
| SKILL.md references slash-command wiring or hooks | Some skills only work when materialized into the runtime by cue | Tell user a hard switch is needed; don't try to fake the hooks. |
| Catalog is stale (skill exists on disk but not in JSON) | Catalog hasn't been refreshed | Fall through to filesystem scan; suggest `bash ~/Documents/cue/resources/skills/scripts/refresh-catalog.sh` later. |
| Multiple candidates match | Topic word is ambiguous | List the top 3 with one-line descriptions, ask which. Don't guess. |

## Examples

### Coolify deploy mid-session

User: "deploy the backend to coolify"
Active profile: `core+skill-writer` (no coolify skill loaded)

```bash
bash ~/Documents/cue/resources/skills/skills/meta/smart-loader/scripts/smart-lookup.sh coolify
# → deployment/coolify  /home/deadpool/Documents/cue/resources/skills/skills/deployment/coolify/SKILL.md  Use when user says "Coolify"...
```

Read the path, tell the user "Smart-loading `deployment/coolify`", then follow its deploy recipe.

### Resend transactional send

User: "send the order confirmation via resend"
Active profile: anything without `resend` loaded.

```bash
bash ~/Documents/cue/resources/skills/skills/meta/smart-loader/scripts/smart-lookup.sh resend
```

Pick the most specific match, Read, apply.

### Topic miss, be honest

User: "use snowflake to query the warehouse"
Lookup returns nothing.

Reply: "No snowflake skill in the catalog. Want me to scaffold one, or do you have a vendor doc I should follow this once?"

## What this skill is NOT

- Not a Skill-tool replacement. Smart-loaded skills don't appear in `Skill()`. The user can't `/<name>` them. They're applied prose-style for the current task only.
- Not a profile switcher. For full MCP + slash-command + plugin reload, `cue use <profile>` is still the answer.
- Not a search engine. It looks in `~/Documents/cue/resources/skills/skills/` only. External repos are out of scope (use `skill-suggestion` for those).

## Linking

- Related: [[skill-suggestion]], proactive "should this be a skill" prompts.
- Related: [[skill-discovery]], end-of-session retro for skill coverage gaps.
- Related: [[profile-suggest]], when the right answer is `cue use <profile>` instead of soft-loading.
