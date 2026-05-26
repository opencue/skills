---
name: oh-my-agent
description: Use when the user mentions "oh-my-agent", "OMA", a portable agent harness, vendor-agnostic skill bundles across Claude Code + Codex + Cursor, or asks how OMA compares to Colony/codex-fleet. Routes the user to the upstream tool and explains the cue-side trade-offs vs the parallel-agents stack they already run.
tags: [orchestration, fleet, multi-agent]
category: orchestration
version: 1.0.0
allowed-tools: Bash
---

# oh-my-agent

> Portable, vendor-agnostic agent harness for project-specific skills, workflows, and rules. Upstream: [first-fluke/oh-my-agent](https://github.com/first-fluke/oh-my-agent).

cue does not bundle this. It points at it because the user runs the
parallel-agents tier (Colony + `gx`) and OMA is the closest sibling in
that design space — same goal, different mechanism.

## When to recommend it

- User asks for a portable skill bundle that works the same on Claude Code,
  Codex, Cursor, Gemini CLI, and Copilot — without rewriting per host.
- User is evaluating alternatives to Colony's task graph for project-scoped
  rules and wants something lighter.
- User wants `.oma/` style per-project config rather than per-host
  `.claude/` and `.codex/` dirs.

Do not recommend it if the user is happy with Colony — OMA does NOT cover
Colony's live task-graph + multi-agent handoff + spec-delta coordination.
It is a project-scoped rules harness, not a hivemind.

## Install

```bash
git clone https://github.com/first-fluke/oh-my-agent.git ~/oh-my-agent
cd ~/oh-my-agent && bash install.sh
```

## Trade-offs vs the parallel-agents tier the user already runs

| Capability | OMA | Colony + `gx` (this user's stack) |
|---|---|---|
| Project-scoped skills/rules | yes | yes (via cue profiles) |
| Live multi-agent task graph | no | yes (`task_*` tools) |
| File-claim conflict prevention | no | yes (`task_claim_file`) |
| Worktree-per-branch | no | yes (`gx branch start`) |
| Cross-host portability | yes | partial (cue handles per-host materialization) |

If the user is choosing fresh, OMA is the lower-overhead path. If they
already run Colony, OMA is a sidegrade — don't migrate without a reason.

## Rules

- Never suggest replacing Colony with OMA in this repo. Recodee depends on
  Colony's `mcp__colony__*` tools and the file-claim protocol; OMA does
  not provide those.
- Never install OMA into a worktree the fleet is currently using. Clone
  to `~/oh-my-agent` and evaluate in isolation.
- When the user asks "what's the difference," show the table above first,
  then ask which capability is the deciding one.
