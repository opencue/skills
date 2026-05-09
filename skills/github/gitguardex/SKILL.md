---
name: gitguardex
description: >-
  Use when repo safety might be broken (failing CI, dirty working tree,
  dropped submodules, weird branch state). Runs the gx (gitguardex)
  guardrail flow — gx status to assess, gx doctor to repair, gx status
  --strict to verify. Bootstrap via gx setup. NOT for code-quality
  review — use code-review.
---

Use when repo safety may be broken.

`gx status` -> `gx doctor` -> `gx status --strict`

Bootstrap: `gx setup`
Ops: `bash scripts/codex-agent.sh "<task>" "<agent>"`, `gx finish --all`, `gx cleanup`
