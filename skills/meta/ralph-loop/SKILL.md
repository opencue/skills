---
name: ralph-loop
description: >
  Use when user says "run this in a loop", "work on it overnight", "keep going
  until done", "ralph loop", "autonomous loop", "make claude work longer", or
  "run until tests pass". Runs an autonomous Ralph-Wiggum loop — re-feeds one
  goal prompt to the agent over and over until a stop condition (tests green /
  PRD done) or a budget/iteration cap, with checkpoints each round. NOT for
  one-shot tasks or interactive back-and-forth.
tags: [meta, cue, automation, autonomous, loop]
category: meta
version: 1.0.0
---

# ralph-loop, make the agent work longer (autonomously)

The "Ralph Wiggum" technique (Geoffrey Huntley: *"Ralph is a Bash loop"*): keep
feeding the agent the **same goal prompt** until the work is actually done. Each
iteration sees the previous round's file changes + git history, so it grinds
toward completion. Huntley famously ran a 3-month loop that built a whole
programming language. The loop is trivial; **the guardrails are the real work.**

## The Iron Law

**No loop without an automated stop condition.** You can't review a 26-hour run
by hand, so the loop must verify *itself*, typically "tests pass" or a checked
acceptance command. A loop with no stop check drifts and burns money. If the
user can't name a verifiable "done", stop and ask for one before looping.

## Two ways to run it

1. **In-session (recommended, safest):** the official Anthropic plugin
   `ralph-wiggum`, a Stop hook intercepts the agent's exit and re-feeds the
   prompt. No external script.
   `/plugin marketplace add anthropics/claude-code` → enable `ralph-wiggum`.
2. **External loop (this skill's `scripts/loop.sh`):** a guarded `while` loop
   that re-runs the agent, runs your stop-check after each round, checkpoints to
   git, and caps iterations. Use when you want it outside a live session.

## Run the included script

```bash
# Loop until `bun test` passes, max 30 rounds, checkpoint each round:
scripts/loop.sh --prompt ./GOAL.md --until "bun test" --max 30 --checkpoint

# Fully unattended (skips permission prompts — ONLY in a sandbox/VM/container):
scripts/loop.sh --prompt ./GOAL.md --until "bun test" --max 30 --yolo
```

`GOAL.md` states the objective **and** the done-criterion in plain text
(e.g. "Implement X. You are done when `bun test` is green and `bun run build`
succeeds."). Stop-check `--until` is the machine-truth that ends the loop.

## Guardrails (do not skip)

- **Stop condition**, `--until "<cmd that exits 0 when done>"`. Required.
- **Cap iterations**, `--max N` (default 50) so a stuck loop can't spin forever.
- **Budget**, the Agent SDK exposes `max_budget_usd` / `maxTurns`; for the CLI,
  the iteration cap is your ceiling. A YC team shipped 6 repos overnight for ~$297,
  cost is real.
- **Sandbox `--yolo`**, unattended mode passes `--dangerously-skip-permissions`,
  which runs arbitrary commands. Only in a throwaway container/VM/worktree.
- **Checkpoint**, `--checkpoint` commits after each round so progress is
  recoverable and you can diff what each iteration did.

## Already in your stack

cue ships a `/loop` skill (interval / self-paced reruns of a prompt or slash
command) and `codex-fleet` for multi-agent orchestration, you can drive a
Ralph loop natively without an external repo. This skill's script is the
zero-dependency fallback.

## Open-source references (verified June 2026, by stars)

| Repo | ⭐ | Note |
|---|---|---|
| `anthropics/claude-code` (`ralph-wiggum` plugin) | 129k | Official Stop-hook loop. Start here. |
| `frankbria/ralph-claude-code` | 9.2k | Loop with intelligent exit detection. |
| `smtg-ai/claude-squad` | 7.7k | Manage many agents in parallel. |
| `mikeyobrien/ralph-orchestrator` | 2.9k | Hardened Ralph orchestration. |
| `michaelshimeles/ralphy` | 2.9k | Bash loop, multi-CLI, runs until PRD complete. |

Source: Huntley's writeups + the official plugin README.
