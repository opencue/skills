---
name: gitguardex
description: >-
  Use when user says "gx doctor", "dirty worktree", or "finish the agent branch". gitguardex guardrails for branch/worktree/lock/PR state. NOT for code-quality review (use code-review).
---

# Gitguardex

Use when repo safety may be broken.

`gx status` -> `gx doctor` -> `gx status --strict`

Bootstrap: `gx setup`
Ops: `bash scripts/codex-agent.sh "<task>" "<agent>"`, `gx finish --all`, `gx cleanup`
