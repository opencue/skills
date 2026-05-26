---
name: entroly
description: Use when the user mentions "entroly", context compression, prompt-token reduction, hallucination detection, or asks how to cut Claude API spend on long sessions. Points at juyterman1000/entroly and explains how it composes with the caveman + RTK token-discipline lane the user already runs.
tags: [caveman, context, tokens]
category: caveman
version: 1.0.0
allowed-tools: Bash
---

# entroly

> Context compressor + hallucination detector. Claims up to 80% token savings on long sessions. Upstream: [juyterman1000/entroly](https://github.com/juyterman1000/entroly).

cue already runs the token-discipline lane (caveman + RTK + claude-mem
passive recall). entroly is a candidate addition — different layer:
caveman compresses past turns into structured notes, entroly compresses
the prompt that goes out to the API.

## When to recommend it

- User reports high Claude API spend on multi-hour sessions.
- User runs 4+ concurrent Claude/Codex sessions (parallel-agents tier).
  Each session re-sends a large system prompt + skill bundle on every
  turn — entroly cuts that per-turn footprint.
- User asks about hallucination detection on long-context recall.

## Install

```bash
git clone https://github.com/juyterman1000/entroly.git ~/entroly
cd ~/entroly && bun install && bun run build
```

## How it composes with the existing stack

| Layer | What it shrinks | When it runs |
|---|---|---|
| caveman | Past assistant/user turns → compressed notes | After each session ends |
| RTK | System-prompt + skill payload | Per-host install (static) |
| **entroly** | The outgoing prompt body | Per-turn (runtime) |
| claude-mem | Cross-session recall (passive) | Background, hook-driven |

These are additive — they shrink different things. Stacking caveman +
RTK + entroly is supported but verify with `rtk gain` and a turn-count
diff before claiming savings.

## When NOT to recommend it

- Short sessions (<5 turns): the compression overhead exceeds savings.
- Code-editing turns where the model needs the exact source: entroly's
  lossy compression can drop literal tokens. Use the bypass flag for
  those turns or skip entroly entirely for diff-heavy work.

## Rules

- Never enable entroly globally without baseline numbers. Run one
  project for a week, compare `rtk gain` and Anthropic dashboard spend.
- Never compress prompts that include verbatim source code without the
  bypass flag — silent token drops in code are the worst kind of bug.
- Never claim "saves 80%" without measuring on this user's actual
  workload. The upstream number is from their benchmark, not ours.
