---
name: gitguardex
description: >
  Use only in GitGuardex-managed repositories when starting, repairing, or
  finishing agent work. Enforces isolated worktrees, file claims, ownership
  checks, compact handoffs, and gated PR completion. NOT for general Git help
  or code-quality review.
category: github
---

# GitGuardex agent workflow

Apply this workflow only when `gx status` recognizes the repository or the
repository contains GitGuardex's managed `.omx` directory. Otherwise follow the
repository's ordinary Git rules.

## Protocol

1. **Inspect the lane.** Run `gx status`. When agents may overlap, call the gx
   MCP `my_context`, then `list_agents`, and `who_owns` for every intended file.
   CLI fallbacks: `gx mcp list-agents --no-prs` and
   `gx mcp who-owns path/to/file`.
2. **Isolate each writer.** Start a separate branch and worktree:
   `gx branch start --tier T1 --no-transfer "<task>" "<agent>"`.
   Transfer existing dirty work only when that lane explicitly owns it.
3. **Claim before editing.** Run
   `gx locks claim --branch "<agent-branch>" <file...>`. One writer owns a file
   at a time. If another lane owns or is actively editing it, split the scope or
   hand it off; do not overwrite or race it.
4. **Keep agents bounded.** Give each writer its branch/worktree, owned paths,
   runnable verification, and stop condition. Read-only scouts may share the
   repository; every mutating agent gets an isolated worktree and non-overlapping
   file set.
5. **Handoff compactly.** Report only branch, worktree, owned files, commit,
   verification, remaining blocker, and the next command. Do not pass session
   transcripts or duplicate work already committed.
6. **Finish once.** The designated lane commits, then runs
   `gx branch finish --branch "<agent-branch>" --via-pr --wait-for-merge --cleanup`.
   In multi-lane work, only the integration/release owner performs the final
   shared release gate; other lanes hand off commits or PRs.

## OpenSpec boundary

OpenSpec is explicit opt-in. Default to T1 and do not create or update
`openspec/` artifacts unless the user explicitly requests OpenSpec or asks to
continue a named OpenSpec change.

## Repair path

When repository safety is already broken, use the smallest repair loop:

```sh
gx status
gx doctor
gx status --strict
```

Do not run repair commands merely because normal implementation work is in
progress.
