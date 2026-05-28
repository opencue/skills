---
name: roi-estimator
description: >-
  Use when generating any list of improvements, recommendations, or changes
  the user could adopt. Adds an ROI column with dimension, bounded percent,
  and confidence tier so the user can prioritize by impact, not by count.
  Also use when the user says "add ROI", "rank by impact", "which one
  matters most", "out of 100%", "estimate impact", or asks how much a
  proposed change would help.
tags: [meta, calibration, output-format]
category: meta
version: 1.1.0
requires_mcps: []
allowed-tools: []
triggers:
  - "add roi"
  - "rank by impact"
  - "which one matters most"
  - "out of 100%"
  - "estimate impact"
  - "how much would this help"
  - "improvement table"
  - "improvements list"
---

# roi-estimator

Every time Claude produces a list of improvements or recommendations, every row carries an ROI estimate. The ROI is a calibrated percentage paired with a dimension and a confidence tier, never a bare marketing number.

This skill rides on the same calibration discipline as `meta/liedetector`. ROI estimates are inherently uncertain; the format makes the uncertainty legible instead of hiding it behind a single confident number.

## Iron contract

1. **Pick one dimension per row.** Every ROI lives on exactly one axis: `accuracy`, `latency`, `turn-efficiency`, `token-cost`, `friction`, or `correctness`. If an improvement helps two dimensions, pick the dominant one and note the secondary in parens.
2. **Bound the percent.** ROI is bounded 0 to 100. Snap to deciles (10, 20, 30, 40, 50, 60, 70, 80, 90). Never `+47%` or `+23%`. Snapping forces honest calibration; false precision lies.
3. **Tag the confidence.** Use the liedetector tiers:
   - 🟢 **measured**, you ran a benchmark, ran both versions, or compared real outputs this session. The number is from data.
   - 🟡 **inferred ~70-80%**, reasoned from verified premises but not measured.
   - 🟠 **guessed ~30-40%**, pattern match, no direct evidence.
   - 🔴 **unknown**, refuse the estimate. Write "ROI: unknown" instead of fabricating.
4. **No additive stacking.** Five improvements at +20% each do not sum to +100%. Each row is independent. Do not compute a "total ROI" line unless you have evidence the gains actually compose (rare).
5. **State the baseline.** "+30% accuracy" means "compared to the pre-change state on the task we just discussed." If the baseline is different (industry average, prior session, theoretical max), say so explicitly.
6. **Be willing to write 🔴 unknown.** Refusing to estimate is the second-most-useful output this skill produces, after the calibrated numbers.
7. **Pair every ROI with an effort estimate.** Raw ROI ranks by impact, not by what to do next: a +50% win that costs three weeks loses to a +30% win that costs ten minutes. Add an effort tier and, per dual-scale, show both the agent time (CC + skill) and the human-team time. The recommendation is ROI relative to effort, never raw ROI. Effort tiers: `XS` (minutes), `S` (under an hour), `M` (a few hours), `L` (a day-plus), `XL` (multi-day, flag as an ocean).

## Format

### Table form (preferred for 3+ items)

Add `ROI` and `Effort` as the last two columns. Sort rows by ROI-relative-to-effort, not by ROI alone.

| # | Improvement | Concrete payoff | ROI | Effort |
|---|---|---|---|---|
| 1 | Ranked lookup | top hit is now the right skill | accuracy +30% 🟡 ~70% | S · 20m CC / 1d human |
| 2 | --exclude-loaded | skips already-loaded skills | turn-efficiency +20% 🟠 ~40% | XS · 10m CC / 2h human |
| 3 | Catalog regen | 257 live paths vs 100 dead | correctness +50% 🟢 measured | M · 1h CC / 1d human |

### Inline form (for 1-2 items or prose lists)

Append a compact tag at the end of the item:

> 1. Ranked lookup puts the right skill at the top. **ROI: accuracy +30% 🟡 ~70%**

### Audit footer (when the list has 3+ rows)

Add a one-line summary under the table so the user sees the shape at a glance:

> ROI audit: 1 measured, 3 inferred, 1 guessed. No row should be acted on without re-reading its confidence tier.

## Dimensions cheat sheet

| Dimension | Means | Typical magnitude |
|---|---|---|
| `accuracy` | percent of cases where the right answer is returned | +10 to +50 |
| `latency` | wall-clock time on the hot path | +20 to +60 |
| `turn-efficiency` | turns saved per task | +10 to +30 |
| `token-cost` | tokens spent per task | +20 to +50 |
| `friction` | manual steps removed | +30 to +70 |
| `correctness` | fewer fabrications, hallucinations, or path errors | +10 to +40 |

If an improvement does not fit any of these, the dimension is wrong or the improvement is theatrical. Pick again or drop the row.

## When to skip the ROI column

- One-item recommendations (nothing to rank against).
- Items that are bug fixes or correctness fixes the user did not ask to prioritize.
- Items where you cannot name the dimension. Write "ROI: 🔴 unknown" rather than fake a number.
- Pure-information lists (status reports, file inventories, audit results without recommendations).

## Anti-patterns

### Marketing inflation

**Bad:** `ROI: massive boost in productivity, +95% 🟢`
Five problems: vague phrase, unbounded number, wrong tier, no dimension, no baseline.

**Good:** `ROI: turn-efficiency +30% 🟡 ~70% (vs current manual cue use switching)`

### Additive stacking

**Bad:**
> Total session ROI: +127% (sum of all five rows).

ROIs do not sum. Two improvements that each shave 30% off the same bottleneck do not shave 60% off, they overlap. Don't.

### False precision

**Bad:** `ROI: accuracy +47.3% 🟢`
Snap to deciles. If you cannot pick a decile honestly, downgrade the tier.

### Padding 🟢 measured

**Bad:** every row tagged 🟢 when you only actually measured one. 🟢 means "I ran it both ways this session." If you reasoned from premises, that is 🟡. If you pattern-matched, that is 🟠.

## When to load this skill

Automatically when:

- Generating any list with 3+ improvements, options, or recommendations.
- Producing an "improvements", "next steps", "what to fix", or "what to ship" table.
- Comparing two or more approaches and the user has to pick one.
- The user explicitly asks for impact estimates, rankings by impact, or "out of 100%" framings.

Skip when:

- The list is single-item.
- The list is informational (audit, inventory, status) without a "you should do X" implication.
- The user has explicitly asked for raw output without commentary.

## Example: a real ROI table

Improvements from the smart-loader build session (recent context):

| # | Improvement | Concrete payoff | ROI | Effort |
|---|---|---|---|---|
| 1 | Catalog regen (cue paths) | 257 live paths vs 100 dead | correctness +50% 🟢 measured | M · 1h CC / 1d human |
| 2 | Ranked lookup | exact-name hit at top, body-match noise at bottom | accuracy +30% 🟡 ~70% | S · 30m CC / 1d human |
| 3 | --exclude-loaded | drops already-loaded skills from results | turn-efficiency +10% 🟠 ~30% | XS · 10m CC / 2h human |
| 4 | AGENTS.md path sweep | upstream phantoms gone | correctness +20% 🟡 ~80% | S · 20m CC / 3h human |
| 5 | Iron rule #6 (verify before recommend) | behavioral guard against fabrication | correctness +20% 🟡 ~60% | XS · 5m CC / 1h human |

ROI audit: 1 measured, 3 inferred, 1 guessed. Stacking these naively would say "+130%", wrong, they overlap (rules 1 and 4 both target the same drift problem). Real composite: probably correctness ~+60-70% on this specific failure mode, accuracy ~+30%, the rest is gravy. By ROI-relative-to-effort, rows 5 and 3 ship first (minutes of work), row 1 is the big measured win but costs the most.

## Linking

- Related: [[liedetector]], the confidence-tier discipline this skill borrows.
- Related: [[profile-optimizer]], produces improvement lists that should always carry ROI.
- Related: [[skill-discovery]], end-of-session retro lists, also a ROI candidate.
