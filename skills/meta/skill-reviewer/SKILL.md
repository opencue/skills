---
name: skill-reviewer
description: >-
  Review, score, rewrite, and scaffold SKILL.md files for cue profiles.
  Use when user says "review this skill", "improve skill", "write a skill",
  "skill audit", "check skill quality", "why isn't this skill triggering",
  or "make this skill better". Also activates when writing new skills or
  auditing a profile's skill coverage.
tags: [meta, cue, skills, quality]
category: meta
version: 2.1.0
requires_mcps: []
allowed-tools: Bash
---

# Skill Reviewer

You review, improve, and write SKILL.md files using proven patterns from
Anthropic's official best practices, the anthropics/skills repo (141k★),
gstack's skill-authoring conventions (`vendor/gstack/`, study target —
not source of truth), and community research (200+ prompt activation tests).

## How to use this skill

This skill body holds the workflow. Three reference files carry the heavier
detail — load on demand, don't inline:

- [references/decision-brief-format.md](references/decision-brief-format.md) —
  D-numbered AskUserQuestion format with ELI10, Recommendation, Pros/Cons,
  Net. Use before any non-trivial rewrite.
- [references/voice.md](references/voice.md) — banned vocabulary, em-dash
  ban, compression examples, effort dual-scale.
- [references/completeness.md](references/completeness.md) — 0–10
  completeness scoring across 7 axes, lake-vs-ocean framing.
- [references/learnings.md](references/learnings.md) — when and how to
  log discoveries via `bin/cue-learnings` so future sessions compound.
- [references/checklist.md](references/checklist.md) — line-by-line lint
  expansion (R001–R008 + manual checks).
- [references/roi-model.md](references/roi-model.md) — full ROI scoring
  model with the data-gathering commands.

Read the references when the workflow says "see references/X.md", not
preemptively.

## Iron contract — what makes a skill work

Skills route via **pure LLM reasoning** — no embeddings, no keyword matching.
Claude reads the `description` field from all available skills (~15,000 char
budget total) and decides which to load. This means:

1. **Description is THE trigger mechanism.** A bad description = a dead skill.
2. **Claude undertriggers by default.** Make descriptions slightly "pushy".
3. **Only SKILL.md body loads on trigger** — referenced files load on-demand.
4. **Conciseness wins.** Every token competes with conversation history.

## Activation rate benchmarks (community-tested, 200+ prompts)

| Approach | Activation rate |
|----------|----------------|
| No optimization | ~20% |
| Simple description | ~20% |
| Optimized description (WHAT + WHEN) | ~50% |
| Optimized + real examples | 72–90% |

## When to activate

- User says "review this skill", "improve skill", "skill audit"
- User says "write a skill for X", "scaffold skill", "new skill"
- User says "why isn't this skill triggering", "skill not activating"
- User says "audit skills in <profile>", "find weak skills"
- User says "rewrite this skill", "make it better"

---

## Step 1 — Diagnose the problem

### For existing skills: Lint + manual review

```bash
cue lint-skill <path-to-SKILL.md> 2>/dev/null
```

Then check what the linter misses:

| Check | What to look for | Why it matters |
|-------|-----------------|----------------|
| **Description: 3rd person** | No "I can" or "You can use" | Injected into system prompt; POV mismatch breaks discovery |
| **Description: WHAT + WHEN** | Both capability AND trigger conditions | Claude needs both to route correctly |
| **Description: pushy enough** | Includes "Use when..." with specific keywords | Claude undertriggers — be explicit about when to activate |
| **Body: under 500 lines** | Count with `wc -l` | Longer = competes with conversation context |
| **Body: concrete steps** | Bash commands, not "consider doing X" | Vague prose doesn't produce reliable behavior |
| **Body: one job** | Does it try to do >3 distinct workflows? | Split if so — focused skills activate more reliably |
| **References: one level deep** | No SKILL.md → file.md → details.md chains | Claude partially reads nested refs with `head -100` |
| **Examples: present** | Input/output pairs for key behaviors | Examples improve activation from 50% → 72-90% |
| **Boundaries: explicit** | "What this skill does NOT do" section | Prevents false-positive activation |
| **CLI deps: declared** | `allowed-tools` + `cli-recipes.json` entry | Skills that shell out to missing tools fail silently |

### For triggering issues specifically:

The description must contain terms from **actual user requests**, not abstract categories:

```
# BAD — 20% activation
description: Helps with documents

# GOOD — 50%+ activation  
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.

# BEST — 72-90% activation (includes context)
description: |
  Extract text and tables from PDF files, fill forms, merge documents.
  Use when working with PDF files, when user mentions PDFs, forms,
  document extraction, or asks to "pull data from this PDF",
  "fill out this form", or "combine these documents".
```

## Step 2 — Score the skill (1–5 activation + 0–10 completeness)

Two scores, two purposes. Activation tells you whether the skill *fires*;
completeness tells you whether it does the whole job once it does.

| Activation score | Meaning | Typical issue |
|-------|---------|---------------|
| 1 | Dead skill | Missing/vague description, no triggers |
| 2 | Rarely activates | Description lacks WHEN clause, body is prose |
| 3 | Works sometimes | Has triggers but missing examples or boundaries |
| 4 | Reliable | Good description, concrete steps, has examples |
| 5 | Excellent | Pushy description, examples, boundaries, feedback loop |

For the completeness score (0–10 across 7 axes), see
[references/completeness.md](references/completeness.md). A skill can be
4/5 on activation but 5/10 on completeness — that's the common pattern
for skills that fire reliably but only cover the happy path.

Present both:

```
Score: 3/5 activation, 6/10 completeness — fires for the obvious phrasings
but no should-not-trigger guards and no examples.
```

## Step 3 — Rewrite using the proven patterns

Before rewriting anything non-trivial (description rewrite, scope split,
exclusion removal), surface the choice as a **D-numbered decision brief**
to the user. The format is in
[references/decision-brief-format.md](references/decision-brief-format.md) —
ELI10 paragraph, Recommendation, Pros/Cons (✅/❌), Net line. Do not
rewrite silently; the user owns scope and trigger surface decisions.

Skip the brief for trivial fixes (typos, R001 auto-fix, single-word
description tweaks).

### Pattern A: Description optimization (the #1 fix)

```yaml
description: >-
  [Capability statement — what it does]. [Secondary capabilities].
  Use when [trigger 1], [trigger 2], or when user mentions
  "[keyword1]", "[keyword2]", "[keyword3]".
```

Rules for descriptions:
- **Always 3rd person** ("Processes files" not "I process files")
- **Under 1024 chars** (hard limit)
- **Include 5+ specific trigger keywords** from real user requests
- **Be slightly pushy** — "Make sure to use this skill whenever..."
- **Mention file types/formats** if applicable (.xlsx, .pdf, etc.)

### Pattern B: Body structure (progressive disclosure)

```markdown
# Skill Title

<1-2 sentences: what + why. No fluff.>

## When to activate
- User says "X"
- User says "Y"  
- Context trigger (e.g., "when a .pdf file is detected")

## Step 1 — <Verb phrase>
<Concrete bash command or action>
<Expected output>

## Step 2 — <Verb phrase>
<Next action>

## Rules
- <Boundary — what NOT to do>
- <Anti-pattern to avoid>

## What this skill does NOT do
- <Explicit exclusion 1>
- <Explicit exclusion 2>
```

### Pattern C: Examples (the activation multiplier)

Examples improve activation from 50% → 72-90%. Include input/output pairs:

```markdown
## Examples

**Example 1:**
Input: <realistic user request with context>
Output: <what the skill produces>

**Example 2:**
Input: <different phrasing, same intent>
Output: <expected result>
```

### Pattern D: Degrees of freedom

Match specificity to task fragility:

- **High freedom** (multiple valid approaches): text instructions, heuristics
- **Medium freedom** (preferred pattern exists): pseudocode with parameters
- **Low freedom** (fragile/critical operations): exact scripts, no modification

### Pattern E: Feedback loops (for quality-critical skills)

```markdown
## Validation loop
1. Run <action>
2. Validate: `<validation-command>`
3. If validation fails → fix → re-validate
4. Only proceed when validation passes
```

## Step 4 — Scaffold new skills

```bash
mkdir -p resources/skills/skills/<category>/<skill-name>
```

Write the SKILL.md using this template:

```markdown
---
name: <skill-name>
description: >-
  <Capability statement>. <Secondary capabilities>.
  Use when <trigger 1>, <trigger 2>, or when user mentions
  "<keyword1>", "<keyword2>", "<keyword3>".
tags: [<category>, <domain>]
category: <category>
version: 1.0.0
requires_mcps: []
allowed-tools: Bash
---

# <Skill Title>

<What this does and why — 1-2 sentences max.>

## When to activate

- User says "<trigger1>"
- User says "<trigger2>"
- <Context trigger>

## Step 1 — <Verb phrase>

```bash
<concrete command>
```

<Expected output or next action>

## Step 2 — <Verb phrase>

<Next concrete action>

## Examples

**Example 1:**
Input: <realistic request>
Output: <expected result>

## Rules

- <Boundary 1 — explain WHY, not just MUST>
- <Boundary 2>

## What this skill does NOT do

- <Exclusion 1 — prevents false-positive activation>
- <Exclusion 2>
```

### Key principles when writing:

1. **Explain WHY, not heavy-handed MUSTs** — Claude is smart, reasoning > commands
2. **Generalize, don't overfit** — skill will be used across many prompts
3. **Keep it lean** — remove anything not pulling its weight
4. **Bundle repeated work as scripts** — if every invocation writes the same helper, pre-bundle it
5. **Test with real requests** — not abstract "process data" but "ok so my boss sent me this xlsx..."

## Step 5 — Audit a profile's skills

```bash
# List skills in the profile
grep "    - " profiles/<profile>/profile.yaml

# Check each exists and has valid frontmatter
for skill in $(grep "    - " profiles/<profile>/profile.yaml | sed 's/.*- //'); do
  echo "--- $skill ---"
  if [ -f "resources/skills/skills/$skill/SKILL.md" ]; then
    head -5 "resources/skills/skills/$skill/SKILL.md"
  else
    echo "⚠ MISSING"
  fi
done
```

Report:
- **Missing skills** — referenced but no SKILL.md
- **Dead skills** (score 1-2) — won't activate reliably
- **Overlapping skills** — two skills covering same triggers
- **Gap analysis** — what the profile needs based on its description
- **Token budget** — total description chars across all skills (budget: 15,000 chars shared)

## Step 6 — ROI analysis + next-step suggestions

After any review, rewrite, or audit, calculate the **ROI of each possible improvement** and present the user with a ranked action list. See [references/roi-model.md](references/roi-model.md) for the full scoring model.

### Quick ROI formula

```
ROI = (frequency × impact × reach) / effort
```

| Factor | What it measures | Scale |
|--------|-----------------|-------|
| **Frequency** | How often this skill/profile is used per week | 1-10 |
| **Impact** | How much better the output gets if fixed | 1-10 |
| **Reach** | How many profiles/users benefit from the fix | 1-10 |
| **Effort** | Time to implement (inverse — lower = easier) | 1-10 |

When the effort estimate involves more than ~10 minutes of CC time,
also report the human-team-equivalent: e.g. "10 min CC / ~half a day
human." Makes the AI compression visible at decision time. The full
voice + dual-scale rules live in
[references/voice.md](references/voice.md).

### How to gather the data

```bash
# Frequency: check skill usage from session transcripts
cue skills rank 20 2>/dev/null

# Reach: how many profiles reference this skill
grep -rl "<skill-name>" profiles/*/profile.yaml | wc -l

# Impact: derived from the score (Step 2)
# Score 1-2 = impact 9-10 (dead skill, huge upside)
# Score 3 = impact 6-7
# Score 4 = impact 3-4
# Score 5 = impact 1 (already excellent)
```

### Present the ranked suggestions

After scoring, output a table like:

```
📊 ROI-ranked improvements (highest first):

  #1  ROI: 54  Fix description on "meta/doctor" (score 2/5, used 12×/week, 4 profiles)
      → Action: rewrite description with WHAT + WHEN + trigger keywords
      → Effort: ~2 min

  #2  ROI: 36  Add examples to "review/code-review" (score 3/5, used 8×/week, 3 profiles)
      → Action: add 2 input/output examples to boost activation 50%→72%
      → Effort: ~5 min

  #3  ROI: 18  Split "deployment/coolify" (score 3/5, 480 lines, used 4×/week)
      → Action: extract reference docs into coolify/references/api.md
      → Effort: ~10 min

  💡 Quick wins (under 2 min each):
  • Add "Use when..." to 3 skills missing WHEN clause
  • Remove 2 dead skills (0 usage, score 1) from backend profile
```

### Suggestion categories

Always end with **one concrete next action** the user can say yes to:

| Category | When to suggest | Example action |
|----------|----------------|----------------|
| **Fix dead skills** | Score 1-2, any usage >0 | "Want me to rewrite the description for X?" |
| **Add examples** | Score 3, no examples section | "Want me to add input/output examples to X?" |
| **Split bloated skills** | >500 lines | "Want me to extract the reference docs into a separate file?" |
| **Remove dead weight** | Score 1, usage 0, >30 days old | "Want me to remove X from the profile?" |
| **Fill gaps** | Profile description implies capability not covered | "Want me to scaffold a new skill for X?" |
| **Optimize descriptions** | Score 3-4, description lacks WHEN | "Want me to add trigger keywords to X?" |
| **Bundle scripts** | Same code generated across multiple invocations | "Want me to pre-bundle this as a utility script?" |

## Rules

- Never approve a skill without a clear WHAT + WHEN in `description:`
- Skills that say "consider" or "you might want to" are weak — rewrite with concrete actions
- A skill >500 lines needs splitting into SKILL.md + reference files
- Always check for overlap before creating a new skill
- Prefer updating an existing skill over creating a near-duplicate
- Run `cue lint-skill` after any rewrite to verify R001-R008 compliance
- Explain WHY behind rules — Claude responds better to reasoning than commands
- Include at least one input/output example for any skill that produces output
- Test descriptions mentally: "would a user typing X cause Claude to pick this skill?"
- Surface every non-trivial rewrite as a decision brief (see
  [references/decision-brief-format.md](references/decision-brief-format.md))
- Apply the voice rules: no em dashes, no banned AI vocabulary
  (see [references/voice.md](references/voice.md))

## Confusion protocol

For high-stakes ambiguity, STOP and ask. Specifically: when a rewrite
would change a skill's trigger surface, when scope might be split,
when the user has not stated which profile owns the skill, or when
two existing skills both partly cover the user's request. One sentence
naming the confusion + a D-numbered brief beats guessing and apologizing.

Do not use the confusion protocol for routine edits (typos, R001 fixes,
adding a missing example).

## What this skill does NOT do

- Run skills (that's the agent's job once the skill is written)
- Manage profiles (use `meta/profile-optimizer` for that)
- Find MCP servers (use `meta/mcp-finder` for that)
- Write CLI recipes (use `meta/cli-writer` for that)
- Execute the iterative eval loop from Anthropic's skill-creator (that requires subagents)

## Capture learnings

If a review surfaced a recurring weakness across this project's skills
(every meta skill missing a Capture-Learnings footer, every review skill
under-triggering on casual phrasings, a specific description antipattern
that keeps appearing), log it so the next audit starts ahead:

```bash
bin/cue-learnings log --type pitfall \
                     --key skill-review-<short-pattern-name> \
                     --insight "<one-line: where it lives, what to check>" \
                     --confidence 1-10 \
                     --source observed
```

Convention: [references/learnings.md](references/learnings.md). Don't log
findings from a single skill — those belong in the review output. Log
patterns that span 2+ skills or 2+ review sessions.
