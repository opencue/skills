---
name: cue-dashboard
description: >-
  Use to inspect or drive the running cue studio dashboard: resolve a profile's
  skills/MCPs, find trigger gaps, or add an MCP to a profile. Via the `cue dash`
  CLI or the cue-dashboard MCP.
tags: [meta, cue, dashboard, mcp, profiles]
category: meta
version: 1.0.0
requires_mcps: [cue-dashboard]
allowed-tools: []
triggers:
  - "ask the dashboard"
  - "query the cue dashboard"
  - "what does cue see"
  - "resolve this profile"
  - "trigger gaps"
  - "add an mcp to"
---

# cue-dashboard

The cue studio dashboard (`cue dashboard`) serves a live REST API at
`http://127.0.0.1:7891/api/v1/*` with everything cue knows: profiles and their
resolved skills/MCPs/plugins, per-skill usage, trigger gaps, active sessions,
the MCP catalog. This skill reads and drives that API two ways: the `cue dash`
CLI (shell) and the `cue-dashboard` MCP (typed tools). Both are thin clients
over the same endpoints; `src/lib/dashboard-server.ts` is the source of truth.

Reach for this to answer "what does cue actually resolve for profile X", to find
coverage gaps, or to add an MCP to a profile without hand-editing YAML. It is
**live** data, unlike `meta/cue-usage` (the static CLI surface) and `cue mcp`
(static on-disk data).

## Prerequisite: the dashboard must be running

Both clients hit a running server. If a call reports it cannot connect, start it:

```bash
cue dashboard            # serves 127.0.0.1:7891; add --port N to move it
```

Point the clients elsewhere with `CUE_DASH_HOST` / `CUE_DASH_PORT` (CLI also
takes `--host` / `--port`).

## CLI vs MCP: pick one

- **`cue dash <cmd>`** when you are already in a shell step and want JSON to pipe
  or grep. Add `--json` for compact output.
- **`mcp__cue-dashboard__*`** when you want a typed tool call mid-conversation
  with no shell. Same data, same endpoints.

## Read commands and tools

| Ask | CLI | MCP tool |
|---|---|---|
| Dashboard + active-profile status | `cue dash status` | `dashboard_status` |
| All profiles + counts | `cue dash profiles` | `dashboard_profiles` |
| One profile's resolved resources | `cue dash profile <name>` | `dashboard_profile_detail` |
| Trigger gaps (matched, never fired) | `cue dash trigger-gaps [profile]` | `dashboard_trigger_gaps` |
| Per-skill usage report | `cue dash skill-report` | `dashboard_skill_report` |
| Profile pair affinity | `cue dash pairs` | `dashboard_pairs` |
| Running cue sessions | `cue dash sessions` | `dashboard_active_sessions` |
| MCP catalog | `cue dash mcps` | `dashboard_mcp_catalog` |
| Discovered plugins | `cue dash plugins` | `dashboard_plugins` |
| Telemetry timeline | `cue dash timeline` | `dashboard_timeline` |

## Mutating commands and tools

These change state. **Confirm with the user before calling**, and prefer
`merge-preview` before `merge-save`.

| Action | CLI | MCP tool |
|---|---|---|
| Add an MCP to a profile | `cue dash add-mcp <profile> <mcp>` | `dashboard_add_mcp` |
| Kill a cue session by pid | `cue dash kill <pid> [--sigkill]` | `dashboard_kill_session` |
| Preview a profile merge | `cue dash merge-preview <a> <b>` | `dashboard_merge_preview` |
| Save a profile merge | `cue dash merge-save <a> <b> --as <name>` | `dashboard_merge_save` |

The kill endpoint refuses any pid that is not a live cue session, so it cannot
terminate arbitrary processes.

## Rules

- Never call a mutating tool (`add-mcp`, `kill`, `merge-save`) without the user
  confirming first. Read tools are free; writes are not.
- Always `merge-preview` before `merge-save`, and report the preview.
- If a call says it cannot reach the dashboard, do not guess the data. Tell the
  user to run `cue dashboard`, or start it yourself if that is in scope.
- Quote the field you read, do not paraphrase it. The dashboard returns live
  JSON; cite the value.
- Prefer `--json` in shell pipelines so the output parses cleanly.

## Example

"Which MCPs does the browser profile resolve, and does it have Playwright?"

```bash
cue dash profile browser --json | jq '.mcps[].id'
# → "cue-tty-watch", "lightpanda", "playwright"
```

Or mid-conversation, call `dashboard_profile_detail` with `{ "profile": "browser" }`
and read `.mcps` from the returned JSON.

## See also

- `meta/cue-usage`: the static cue CLI surface (profiles, skills, marketplace).
- `cue dashboard`: boots the server these clients talk to.
