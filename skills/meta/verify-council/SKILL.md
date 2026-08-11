---
name: verify-council
description: >-
  Use when finishing a visual or hard-to-reverse change, or the user says
  "council", "panel of agents", or "visually verify". Runs independent verifier
  lanes plus a real-screen proof, token-scaled.
tags: [meta, verification, review, workflow]
category: meta
version: 1.0.0
requires_mcps: []
allowed-tools: []
triggers:
  - "verify with a council"
  - "council of agents"
  - "panel of agents"
  - "verify harder"
  - "visually verify"
  - "prove it visually"
  - "second opinion on this change"
---

# verify-council

The closing "VERIFIED" step is where false confidence hides. One auditor shares
the author's blind spots, and a visual claim "checked" by reading the render
code is at best `[INFERRED]`, never `[VERIFIED]`. This skill replaces the single
self-check with a small **council** of independent verifier lanes that run in
parallel, one of which drives the **real screen** and reports a measured value.

It is the panel upgrade to `/verify` (one auditor). Use `/verify` for a quick
single check; use this when the change is visual, decision-critical, or hard to
reverse, and you want diverse lenses plus a real-screen proof.

## When to activate

Run the council as the last step of a turn when **all three** hold (the
`/verify` triage gate):

1. **Decision-relevant**: the user will act on the result.
2. **Hard to reverse**: being wrong costs real recovery (shipped bug, wrong
   layout, broken contract).
3. **Mechanically checkable**: a fresh agent can confirm by reading files,
   running a command, or measuring the rendered screen.

Skip it for cosmetic or one-line changes: an inline `[VERIFIED]` with a quoted
line is enough. In minimal-safe-mode, ask before spawning the lanes.

Also activate on: "council", "panel of agents", "verify harder", "visually
verify".

## Phase 0: triage and mechanical gate (free, no agents)

Run the deterministic checks **first**. They are free and catch most breakage
before a single agent is paid for.

```bash
bun test <touched-files>     # or the project's test runner
bun run typecheck            # tsc --noEmit
bun run lint                 # biome / eslint
```

If any gate fails, stop and fix it. Reviewing broken code with agents wastes
tokens. Then classify the change surface, which decides the lanes:

- `code`: logic only, no rendered surface.
- `tui`: a terminal UI (cue picker, dashboards drawn to the pane).
- `web`: the `web/` dashboard or any browser surface.

## Phase 1: the council (parallel, scoped, cheap models)

Spawn only the lanes the change needs. Each lane gets the **diff and the list of
claims**, not the repo, and returns a structured verdict. Lanes run on a cheap
model (sonnet); the author adjudicates on the strong one.

| Lane | When | What it does | Returns |
|---|---|---|---|
| A correctness | always | Re-derives each logic claim against the diff, neutral prompt, no shared context | PASS / FAIL / PARTIAL + quoted line |
| B red-team | always for code | Runs the CRITICAL/HIGH review pass over the diff | findings or `REVIEW_CLEAN` |
| C visual | surface is `tui` or `web` | Drives the real screen and measures it (see below) | observed value vs claim |
| D skeptic | claim is hard to reverse | Independent refuter, told to REFUTE, default refuted when unsure | refuted? + reason |

The visual lane is the one that turns yellow into green:

- **TUI**: drive the actual terminal with the `cue-tty-watch` MCP: launch the
  app in a tmux pane (`tmux_pane`), `send_keys_tmux` to reach the target state,
  `screenshot`, then `find_text` or `ask_about_image` to assert the rendered
  claim (footer string present, columns aligned).
- **Web**: drive the dev server with `browser/ego-browser`, one heredoc:
  `page.goto(<url>)`, then `page.evaluate()` returning `getComputedStyle()` /
  `getBoundingClientRect()` for the relevant selectors, and report the measured
  pixel values. `page.screenshot()` when the claim is about what it looks like
  rather than what it measures.

## Phase 2: adjudication (author, strong model)

The lanes surface disagreement; the **source settles** it. For every FAIL,
PARTIAL, or finding:

- Re-read the source at its **absolute** path. Quote the exact line, do not
  paraphrase. Use `grep -H` (never `-h`) so a match is credited to the right
  file.
- If the source confirms the lane, issue a `[CORRECTION]` per the liedetector
  protocol and fix it.
- If the source contradicts the lane, the source wins; the lane finding was a
  hallucination, no correction.
- A claim earns `[VERIFIED]` only when its lane PASSed with quoted or measured
  evidence. A **visual** claim needs the Phase 1 measurement, never a code read.

Fix every real CRITICAL and HIGH, re-run the relevant Phase 0 gate to prove the
fix, then write the confidence audit and sign off.

## Running it

**Preferred (Claude Code): the Workflow engine.** It encodes the adaptive
fan-out, schema-validated verdicts, and the parallel barrier in one place. Pass
the capped diff, the claim list, and the surface as `args`:

```text
Workflow({
  scriptPath: ".../meta/verify-council/references/workflow.js",
  args: { diff, claims, surface, hardToReverse, appCmd, url }
})
```

Read the returned verdicts and run Phase 2 yourself. The engine spends nothing
on adjudication, keeping the strong model out of the fan-out.

**Fallback (no Workflow tool, e.g. Codex): manual fan-out.** Spawn the same
lanes with the Agent tool, one per lane, using the neutral prompts in
[references/lane-prompts.md](references/lane-prompts.md). The protocol is
identical; only the orchestration differs.

## Token discipline

This runs "each time" only because it stays cheap:

- Mechanical gate short-circuits before any agent; triage early-exits trivial
  diffs to zero agents.
- Lanes see the diff and claims, capped at 60k chars, not the repo.
- Adaptive count: 2 lanes default, plus the visual lane only when visual, plus
  the skeptic only when hard to reverse.
- Cheap model for lanes; strong model only for adjudication.
- One parallel barrier, so wall-clock is the slowest lane, not the sum.
- Each lane carries a fixed floor (~35k tokens for agent boot + tool registry),
  so the council pays off only for genuinely high-stakes changes. For the rest, a
  clean mechanical gate is the right answer: do not convene a council for a diff
  the test suite already proves.
- Pass the diff INLINE, not via a fetch command. An inline diff gives the lane
  nothing to roam toward; handed only a command, an agent tends to explore the
  wider repo (more tokens, unscoped findings).

## Rules

- Never tag a visual claim `[VERIFIED]` from a code read. The visual lane's
  measured value is the only path to green for layout, spacing, or rendered text.
- Never trust a FAIL on its own. Re-read the source at its absolute path and
  quote the line before acting.
- Never skip Phase 0. Paying agents to review code that fails its own tests is
  the most wasteful mistake here.
- Never spawn the heavy lanes for a cosmetic diff. Match the lane count to the
  stakes.
- In minimal-safe-mode, ask before spawning the council.

## Example

A TUI footer + column-alignment change to the cue profile picker
(`src/lib/picker.ts`). Surface is `tui` and the layout is hard to reverse, so
the council runs correctness + red-team + visual.

```text
1. Phase 0 (free):   bun test src/lib/picker.test.ts  → 155 pass
                     bun run typecheck                → clean
2. Phase 1 (council): correctness + red-team over the diff, plus the visual lane:
   cue-tty-watch launches the picker in a tmux pane, keys to the combine screen,
   screenshots it, find_text "⏎ enter to continue" → present; columns aligned.
3. Phase 2 (author): no FAILs to adjudicate → the footer claim moves from
   🟡 [INFERRED] (read the render code) to 🟢 [VERIFIED] (measured on screen).
```

## See also

- `/verify`: the single-auditor fast path this skill scales up.
- `/code-review-deep`: the standalone diff review that lane B reuses.
- `meta/liedetector`: the confidence-tag output contract Phase 2 writes in.
