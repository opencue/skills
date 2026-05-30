---
name: integrity-tags
description: "Explains cue's 7-tag confidence system (VERIFIED, KNOWN, INFERRED, ASSUMED, GUESSED, STALE, UNKNOWN) used to label every research- or decision-relevant claim. Use when user says \"what does VERIFIED mean\", \"explain the colored tags\", \"what's the confidence system\", \"why is this yellow\", \"what does [ASSUMED] mean\", or asks about cue's integrity protocol."
tags: [meta, cue, integrity, calibration, confidence]
category: meta
version: 1.0.0
requires_mcps: []
---

# Integrity Tags — cue's Confidence System

Every claim cue makes on a research- or decision-relevant response carries a colored tag like 🟢 `[VERIFIED]` or 🟡 `[INFERRED ~80%]`. The tag tells you *how* the agent came to believe the claim and *how strongly* you should trust it.

The full protocol lives at `resources/personas/integrity-protocol.md` and is pulled into every cue profile's persona via `persona_includes: [integrity-protocol]` on `core`. This skill explains the tags for anyone reading cue output without prior context.

## The 7 tags, by color tier

### 🟢 Green — trust by default (~90–99%)

| Tag | Meaning | Reader action |
|---|---|---|
| 🟢 `[VERIFIED]` | I checked the source firsthand this session — read the code, ran the test, opened the spec | Act on it |
| 🟢 `[KNOWN]` | Well-documented public fact from training data — RFCs, language specs, mainstream library APIs | Act on it, unless this project deviates from the norm |

### 🟡 Yellow — reasonable, verify if stakes matter (~50–85%)

| Tag | Meaning | Reader action |
|---|---|---|
| 🟡 `[INFERRED]` | Logical deduction from verified premises. Premises checked, conclusion not | Spot-check before relying on it |
| 🟡 `[ASSUMED]` | Taken as true to make forward progress. Stated so you can override | Override if it matters; otherwise let it ride |

### 🟠 Orange — weak basis, verify before acting (~20–45%)

| Tag | Meaning | Reader action |
|---|---|---|
| 🟠 `[GUESSED]` | Educated guess from pattern-match, no direct evidence | Treat as hypothesis, not ground truth |
| 🟠 `[STALE]` | Was true at training cutoff; API/library/spec may have moved | Always re-check current docs |

### 🔴 Red — don't trust, don't fabricate (~0–10%)

| Tag | Meaning | Reader action |
|---|---|---|
| 🔴 `[UNKNOWN]` | Outside reliable knowledge. Agent is saying so instead of fabricating | Hand off to a search or to a human |

## Optional `~N%` calibration

On yellow and orange tags, the agent may append a decile-snapped estimate:

- 🟡 `[INFERRED ~80%]` — leans high within the yellow tier
- 🟡 `[ASSUMED ~50%]` — leans low within the yellow tier
- 🟠 `[GUESSED ~30%]` — typical for the orange tier

**Rules:**
- Snapped to deciles (20 / 30 / 40 / 60 / 80 / 90) — never `~67%` (false precision)
- Always prefixed with `~` to signal estimate
- Skipped on green and red (the tier already says it)
- The number is meaningful as *relative ordering* across claims in the same response, **not** as a literal calibrated probability — LLM self-reported probabilities are notoriously miscalibrated as absolute values

## The corrective loop

When a prior claim turns out wrong, the agent emits:

> 🟠 `[CORRECTION]` Earlier I said X. I now think Y. Reason: Z.

This is the one tag that's allowed to override an earlier `[VERIFIED]` — it means "I was wrong and I'm fixing it before continuing."

## Confidence audit at end of response

Triggered when the response (a) contains 2+ yellow-or-worse claims, (b) recommends a decision the user will act on, or (c) summarizes external evidence. Ends with:

```
### Confidence audit
- Evidence quality: Strong / Moderate / Weak / Insufficient
- Biggest confidence limiter in this response
- One thing to verify externally before acting
```

## Rules

- Pick the **most specific** tag that fits — "I read the file just now" is `[VERIFIED]`, not `[KNOWN]`
- **Downgrade by default** when between two tiers — false confidence hurts more than false hedging
- Don't grade-inflate — if you didn't actually check, it isn't `[VERIFIED]`
- Skip tags on trivial requests (one-line fixes, simple lookups) — the protocol catches hallucinations on real decision work, not to bloat every reply

## See also

- `resources/personas/integrity-protocol.md` — canonical protocol, included in every profile via `persona_includes`
- `meta/skill-reviewer` — how skill descriptions get linted (cue's lint rules R001-R008 are the structural counterpart to the integrity tags)
