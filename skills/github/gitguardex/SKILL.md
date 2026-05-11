---
name: gitguardex
description: >-
  Use when user says "repo safety is broken", "gx doctor", "dirty worktree",
  or "finish the agent branch" and needs gitguardex guardrails for branch,
  worktree, lock, PR, or cleanup state. Runs gx status, gx doctor, and strict
  verification. NOT for code-quality review; use code-review.
---

# Gitguardex

Use when repo safety may be broken.

`gx status` -> `gx doctor` -> `gx status --strict`

Bootstrap: `gx setup`
Ops: `bash scripts/codex-agent.sh "<task>" "<agent>"`, `gx finish --all`, `gx cleanup`
