---
name: profile-summon
description: >-
  Use when a directory has no .cue-profile, or the user says "summon",
  "load", "apply", or "pull in" a profile, or "no profile here". Soft-loads
  a profile's persona and skills into the LIVE session and pins it, no restart.
tags: [meta, cue, routing, profile]
category: meta
version: 1.0.0
requires_mcps: []
allowed-tools: Bash(cue:*), Bash(jq:*), Read
triggers:
  - "summon a profile"
  - "load a profile"
  - "apply the vercel profile"
  - "pull in the X profile"
  - "no profile here"
  - "bind a profile"
  - "which profile for this repo"
---

# profile-summon

## Prerequisites

- `cue` CLI on PATH (the profile manager that ships this skill).
- `jq` (`apt install jq` / `brew install jq`) to read `cue summon --json`.

Open a directory with no `.cue-profile` and the right profile's skills and MCPs
normally need a pin plus a full `claude` restart, because `CLAUDE_CONFIG_DIR`, the
`Skill()` list, MCP servers, `/slash` commands, and plugins are all frozen at boot.
This skill is the bridge: it binds a profile into the **running** session now and
hands back a warm re-exec for the parts a soft load cannot provide.

## Two tiers, honestly

1. **Now, zero restart (soft-load).** `cue summon` lists the profile's persona and
   each skill's `SKILL.md` path. You `Read` those paths and apply the persona plus
   the relevant skill playbooks inline. Same mechanism as `meta/smart-loader`, just
   whole-profile.
2. **Durable plus full fidelity (warm re-exec).** `cue summon` pins `.cue-profile`
   so the next launch is correct, and prints `claude --continue`. Running that
   resumes THIS conversation under the fully materialized profile, the only path to
   its MCP servers and `/slash` commands.

## Iron contract

1. **Never fake the harness.** MCP tools, `/slash` commands, and plugins cannot be
   hot-added. Do not pretend to call an MCP tool or run a `/command` that is not in
   your actual tool list. The warm re-exec is the sanctioned path to them.
2. **Only follow SKILL.md you actually read.** Read each path from `cue summon`
   output this session before applying it. No paraphrasing from memory.
3. **Honest framing.** Tell the user once, plainly, what soft-loaded and what still
   needs `claude --continue` (see the example below).
4. **Propose, then apply.** On a no-profile directory, show the detected profile and
   what it will soft-load in 3 to 4 lines, then apply on the user's OK. Do not inject
   a profile's persona silently.
5. **One summon per topic per session.** Once a profile is soft-loaded, it stays
   applied. Do not re-run for the same directory.

## When to summon

Summon when **any** holds:

- The directory has no `.cue-profile` (the first-time launch block points here).
- The user names a profile to load: "summon vercel", "apply the backend profile".
- The user asks "which profile for this repo" and wants it active now, not later.

Do not summon when a `.cue-profile` is already pinned and active, or when a loaded
skill already covers the task (use `Skill()` directly).

## The recipe

### Step 1, resolve and inspect

Auto-detect from the repo, or pass an explicit profile:

```bash
cue summon --json            # auto-detect from cwd
cue summon vercel --json     # force a known profile
```

Parse the result. The useful fields:

```bash
cue summon vercel --json | jq '{profile, detected, confidence,
  soft_loadable: [.skills[] | select(.mcp_status=="ok") | {id, path}],
  gated: [.skills[] | select(.mcp_status!="ok") | {id, mcp_status}],
  mcps, commands, plugins, reexec_cmd}'
```

`--json` writes the `.cue-profile` pin by default. Add `--no-pin` to inspect first,
`--pick` to list candidates without acting, `--dry-run` to compute and write nothing.

### Step 2, propose

When you auto-detected (no profile named), show the user a short proposal before
applying:

```
No .cue-profile here. Detected: vercel (97% match: vercel.json, @vercel dep).
Summon it? Soft-loads persona + N skills now, pins .cue-profile, no restart.
The Vercel MCP and /deploy need `claude --continue` after.
```

### Step 3, apply inline

On the user's OK, apply the persona, then `Read` each `mcp_status:"ok"` skill path
and follow the ones the task needs. Skills with `mcp_status:"missing:..."`, npx
skills, `/slash` commands, and plugins do not soft-load: list them as available
after the warm re-exec.

### Step 4, hand back the warm re-exec

Close with the honest summary:

> Soft-loaded the `vercel` persona plus N skill playbooks into this session and
> pinned `.cue-profile`. The Vercel MCP (`mcp.vercel.com`) and `/deploy` `/env`
> commands ride in the plugin, which needs the harness. To get them, run
> `claude --continue`: it resumes this exact conversation under the full profile.

## What can never be faked (needs `claude --continue`)

| Capability | Why it is frozen | Soft-load? |
|---|---|---|
| MCP servers (e.g. `mcp.vercel.com`) | Registered at `claude` boot from CLAUDE_CONFIG_DIR | No |
| `/slash` commands (`/deploy`, `/env`) | Wired into the harness at boot | No |
| Plugins | Loaded at boot | No |
| `Skill()` invocation of a new skill | Skill list frozen at boot | No (apply as prose) |
| Skill **playbooks** (the SKILL.md body) | Plain files on disk | **Yes** |
| Profile **persona** | Plain prose | **Yes** |

## Example: Vercel summon

User opens a Next.js plus Vercel repo (has `vercel.json`) with no `.cue-profile`.

```bash
cue summon --json | jq '{profile, confidence, reasons}'
# → { "profile": "vercel", "confidence": 0.97,
#     "reasons": ["vercel.json", "package.json @vercel/* or vercel"] }
```

Propose `vercel`, apply on OK: persona plus the soft-loadable skills (`agent-browser`,
the framework playbooks) apply now. The hosted MCP, `/deploy`, and `/env` are flagged
as needing `claude --continue`. The pin is written so that re-exec lands the full
profile and resumes the chat.

## What this skill is NOT

- Not an MCP shim. It never calls `mcp.vercel.com` for you.
- Not a slash-command emulator. `/deploy` stays a harness command.
- Not a search engine. To find one off-profile skill for a topic, use
  `meta/smart-loader`. profile-summon binds a whole profile.

## Linking

- Related: [[smart-loader]], soft-loads a single off-profile skill by topic.
- Related: [[profile-suggest]], suggests a profile when none is pinned.
- Related: [[focus]], routes among already-loaded skills.
