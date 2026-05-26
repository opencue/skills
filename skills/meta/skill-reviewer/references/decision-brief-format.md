# Decision-brief format for AskUserQuestion

Adapted from the gstack convention. Every AskUserQuestion the skill-writer
asks should be a decision brief, not a bare options list. The brief gives
the user enough context to decide in one read.

## Format

```
D<N> — <one-line question title>
Project/branch/task: <one short grounding sentence>
ELI10: <plain English a 16-year-old could follow, 2-4 sentences, name the stakes>
Stakes if we pick wrong: <one sentence on what breaks>
Recommendation: <choice> because <one-line reason>
Completeness: A=X/10, B=Y/10   (or: Note: options differ in kind, not coverage — no completeness score)
Pros / cons:
A) <option label> (recommended)
  ✅ <pro — concrete, observable, ≥40 chars>
  ❌ <con — honest, ≥40 chars>
B) <option label>
  ✅ <pro>
  ❌ <con>
Net: <one-line synthesis of what you're actually trading off>
```

## Rules

- **D-number** every brief in a single skill invocation: D1, D2, D3…
- **ELI10 is always present.** Plain English, not function names. Name the
  stakes.
- **Recommendation is always present.** Even on neutral-posture taste calls,
  pick a default and label it `(recommended)`.
- **Completeness scoring:** use `Completeness: N/10` only when options differ
  in *coverage* (10 = all edge cases handled, 7 = happy path, 3 = shortcut).
  If options differ in *kind*, write: `Note: options differ in kind, not
  coverage — no completeness score`. Never fabricate a score.
- **Pros/cons:** minimum 2 ✅ pros and 1 ❌ con per real option. Each bullet
  ≥40 chars. Hard-stop one-way doors may escape with `✅ No cons — this is
  a hard-stop choice`.
- **Effort dual-scale:** when an option involves effort, label both
  human-team and CC time, e.g. `(human: ~2 days / CC: ~15 min)`. Makes AI
  compression visible at decision time.
- **Net line** closes the tradeoff in one sentence.

## When to use

- Before any non-trivial rewrite (description change, scope split, removal).
- Before scaffolding a new skill when an existing one *could* be extended.
- Before recommending a profile change that affects other skills.

## When NOT to use

- Trivial cosmetic edits (typo fix, R001 auto-fix).
- Pure information requests ("how does the linter score X?").
- When the user already gave a direct instruction.

## Example

```
D1 — Split bloated skill or extract a reference file?
Project/branch/task: meta/skill-reviewer is 540 lines and trips R007 (>500 line cap).
ELI10: The reviewer skill outgrew its file. We can either split it into two
focused skills (one for review, one for scaffolding) or move the big tables
into a reference file the skill loads on demand. Splitting changes how it
triggers; extracting keeps the trigger surface identical.
Stakes if we pick wrong: split too aggressively and we double-trigger on the
same prompt; extract when the workflows are actually different and we leave
a confused skill on disk.
Recommendation: B — extract references — the workflows aren't actually
distinct, they just outgrew one file.
Completeness: A=8/10 (real refactor), B=10/10 (preserves all behavior)
A) Split into skill-reviewer + skill-scaffolder
  ✅ Each skill has a single job — descriptions get sharper
  ✅ Trigger phrases stop fighting for the same prompts
  ❌ Profiles referencing skill-reviewer all need updating
B) Extract big tables to references/ (recommended)
  ✅ Zero profile churn — paths stay the same
  ✅ SKILL.md body drops below the 500-line cap immediately
  ❌ Reviewer must read the reference file on demand — small token cost
Net: A is a real refactor with breakage risk; B is the cheap fix that
preserves all behavior. Pick B unless we have evidence the two workflows
actually conflict.
```
