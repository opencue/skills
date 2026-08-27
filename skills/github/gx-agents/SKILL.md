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
  Use in GitGuardex-managed repositories when multiple agents or subagents need
  ownership-aware coordination across branches, worktrees, files, or PRs.
  Drives the read-only gx radar tools before delegation and scope changes. NOT
  for repository repair (use gitguardex).
---

# gx agent radar and handoffs

Use this skill only where GitGuardex is active (`gx status` succeeds or the
managed `.omx` directory exists). The radar is read-only; file claims and
worktree creation remain explicit GitGuardex operations.

## Before delegation or edits

1. Call `my_context` to confirm the current repo, branch, worktree, dirty files,
   locks, and PR.
2. Call `list_agents` to see active lanes. Request PR data only when PR state is
   needed.
3. Call `who_owns` for every file a writer may touch.

CLI fallbacks when the gx MCP is unavailable:

```sh
gx mcp list-agents --no-prs
gx mcp who-owns path/to/file
```

Re-run the radar before expanding file scope, taking a handoff, or starting the
final finish flow. `who_owns` can lag an uncommitted edit, so cross-check another
lane's dirty files in `list_agents`.

## Collaboration contract

- Give every mutating agent a separate branch/worktree and an explicit file
  claim. A read-only scout does not need a claim.
- Keep one writer per file. Shared integration files belong exclusively to the
  designated integrator; downstream agents hand off patches or commits instead
  of editing the same file concurrently.
- Assign one bounded job per agent: owned paths, expected artifact, verification
  command, and stop condition. Do not delegate vague repo-wide cleanup.
- OpenSpec remains explicit opt-in. Do not introduce OpenSpec artifacts merely
  because several agents are collaborating.
- Choose one integration/release owner. Other lanes stop after their verified
  commit or PR and hand off; they do not independently run the shared finish.

## Compact handoff

Use this shape and omit empty fields:

```text
branch: <agent/...>
worktree: <absolute path>
owns: <paths>
commit: <sha or uncommitted>
verified: <commands + result>
remaining: <blocker or next task>
next: <single command/action>
```

Do not paste transcripts, large diffs, or discovery dumps. The receiving agent
must verify the commit and ownership state before continuing.
