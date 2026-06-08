---
name: gx-agents
category: github
triggers:
  - who's working on what
  - show all agents
  - is anyone else editing
  - agent collision
  - which PR is each agent shipping
  - who owns this file
  - agent radar
description: >-
  Use when several agents work in parallel and you need to see who is on which branch, worktree, or PR, or to avoid editing a file another agent already owns. Triggers: "who's working on what", "show all agents", "is anyone else editing X", "agent collision", "which PR is each agent shipping", "who owns this file", "agent radar". Drives the gx mcp tools (list_agents, who_owns, my_context) or the `gx mcp list-agents` / `gx mcp who-owns` CLI to read every agent's branch, worktree, dirty files, locks, and PR. Read-only. NOT for repo-safety repair (use gitguardex).
---

# gx agents: see every agent, avoid collisions

Multiple agents (Claude, Codex) editing nearby repos step on each other: two
edit the same file, or one edits the protected primary checkout and a later
branch switch auto-stashes the work. `gx mcp` exposes the live picture
gitguardex already tracks. Read it BEFORE you edit, not after the conflict.

## Prereq

The server ships with gitguardex (`gx mcp serve`). Register it once so any
session can call the tools:

```sh
claude mcp add gx -s user -- gx mcp serve
```

If it is not registered, use the CLI fallback below: same data, no MCP client.

## Before you edit a shared file: check ownership

Ask who holds the lock before touching a path. If another branch owns it,
coordinate or pick a different file instead of overwriting.

```sh
gx mcp who-owns path/to/file.ts
# -> "locked by <agent> (branch agent/<name>/...)"  or  "unclaimed"
```

MCP tool form: call `who_owns` with `{ "file": "path/to/file.ts" }`.

## See the whole field

List every active agent lane across all your repos: branch, worktree, the
files each is editing right now (`dirty`), held locks, last commit, and PR.

```sh
gx mcp list-agents            # human view
gx mcp list-agents --json     # machine view (pass --no-prs to skip gh/network)
```

MCP tool form: call `list_agents` (pass `{ "include_prs": true }` when you need
PR state, which is off by default to keep the cross-repo scan fast).

Watch for `⚠ ON PRIMARY CHECKOUT`: that lane is editing the protected base, not
an isolated worktree, so its work can be auto-stashed. Tell it to move with
`gx branch start`.

## Know your own lane

```sh
# MCP tool: my_context  -> repo, branch, worktree, onPrimaryCheckout, dirty, locks, PR
```

## Example

User: "before I touch the checkout component, is anyone else on it?"

```sh
gx mcp who-owns apps/storefront/src/checkout-delivery-step.tsx
# -> locked by codex (branch agent/codex/checkout-copy-fix)
gx mcp list-agents --no-prs | grep -A3 checkout
# -> codex  agent/codex/checkout-copy-fix   editing 4 file(s)
```

Conclusion: codex owns it and is editing it right now. Pick different work or
post a handoff instead of overwriting.

## Rules

- **Read-only.** These tools never change a repo. To actually reserve a file,
  use `gx locks claim --branch "<branch>" <file>`; to coordinate live tasks,
  use Colony. `gx mcp` only shows the state.
- **Locks lag edits.** File locks are written at commit time, so `who_owns` can
  return `unclaimed` while another lane is mid-edit. Cross-check the lane's
  `dirty` files in `list_agents` for in-progress work.
- **One agent per file.** If `who_owns` (or another lane's `dirty`) shows the
  file is taken, do not overwrite. Post a handoff or pick different work.
- **Act on the primary-checkout warning.** A lane on the primary checkout is the
  collision waiting to happen; route it to `gx branch start` first.
- **This is not gitguardex repair.** For broken repo safety (dirty worktree,
  stuck finish, `gx doctor`) use the `gitguardex` skill instead.
