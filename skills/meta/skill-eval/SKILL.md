---
name: skill-eval
description: >-
  Scaffold evaluation scenarios for skills, run them, and measure
  activation rate and output quality. Use when user says "test this skill",
  "eval skill", "does this skill work", "measure activation", "benchmark
  skill", or "create evals for this skill". Implements Anthropic's
  evaluation-driven development approach.
tags: [meta, cue, skills, testing, evals]
category: meta
version: 1.0.0
requires_mcps: []
allowed-tools: Bash
---

# Skill Eval

Scaffold and run evaluations for skills. Based on Anthropic's principle:
"Build evaluations BEFORE writing extensive documentation."

## When to activate

- User says "test this skill", "eval skill", "benchmark skill"
- User says "does this skill work?", "measure activation"
- User says "create evals", "write test cases"
- After writing or rewriting a skill (as verification step)

## Step 1 — Identify the skill and its claims

```bash
# Read the skill
cat <path-to-SKILL.md>
```

Extract:
- **Trigger claims** — what phrases should activate it?
- **Output claims** — what should it produce?
- **Boundary claims** — what should it NOT do?

## Step 2 — Scaffold eval scenarios

Create 3 categories of test prompts:

### A. Should-trigger prompts (3-5)

Realistic user requests that SHOULD activate this skill. Make them:
- Varied in phrasing (formal, casual, typos)
- Substantive (not one-liners — Claude skips skills for trivial tasks)
- Context-rich (file paths, project details, backstory)

```json
[
  {
    "id": 1,
    "prompt": "realistic user request with context and detail",
    "should_trigger": true,
    "expected_behavior": "what the skill should do"
  }
]
```

### B. Should-NOT-trigger prompts (3-5)

Near-miss queries that share keywords but need a different approach:

```json
[
  {
    "id": 6,
    "prompt": "adjacent request that shares keywords but needs different skill",
    "should_trigger": false,
    "why_not": "because this is actually X, not Y"
  }
]
```

### C. Edge-case prompts (2-3)

Ambiguous requests that test the skill's boundaries:

```json
[
  {
    "id": 9,
    "prompt": "ambiguous request at the boundary",
    "should_trigger": "maybe",
    "notes": "acceptable either way, but if triggered should handle gracefully"
  }
]
```

## Step 3 — Save the eval set

```bash
mkdir -p <skill-dir>/evals
cat > <skill-dir>/evals/eval-set.json << 'EOF'
{
  "skill_name": "<name>",
  "skill_path": "<path>",
  "created": "<date>",
  "scenarios": [
    ... all scenarios from Step 2 ...
  ]
}
EOF
```

## Step 4 — Run activation test

For each should-trigger prompt, assess: "Given the skill's description
in a list of 20+ other skill descriptions, would Claude select this one?"

Score:
```
Activation Results:
  Should-trigger:     X/5 activated correctly
  Should-NOT-trigger: X/5 correctly ignored
  Edge cases:         X/3 handled gracefully

  Overall activation score: X/13
  Target: ≥11/13 (85%)
```

## Step 5 — Run output quality test (if skill activated)

For each triggered scenario, assess the output against `expected_behavior`:

| Scenario | Triggered? | Output quality | Notes |
|----------|-----------|----------------|-------|
| #1 | ✓ | Good — followed steps | |
| #2 | ✓ | Partial — skipped step 3 | Body needs clearer instruction |
| #3 | ✗ | N/A | Description missing keyword |

## Step 6 — Diagnose failures and suggest fixes

For each failure, identify the root cause and fix:

| Failure type | Root cause | Fix |
|-------------|-----------|-----|
| Didn't trigger | Description missing keyword | Add keyword to description |
| Didn't trigger | Query too simple | Skill can't help — this is expected |
| False positive | Description too broad | Add "Do not use for X" boundary |
| Triggered but wrong output | Body instructions unclear | Rewrite step with concrete command |
| Triggered but incomplete | Missing step in workflow | Add the missing step |

## Step 7 — Present results and next action

```
📋 Skill Eval Results: "<skill-name>"

  Activation:  11/13 (85%) ✓ meets target
  Quality:     4/5 scenarios produced correct output

  Failures:
  • Scenario #3: didn't trigger — description missing "contract" keyword
  • Scenario #5: triggered but skipped validation step

  Suggested fixes (ROI-ranked):
  1. Add "contract" to description triggers (2 min, fixes #3)
  2. Add explicit "validate before proceeding" in Step 3 (5 min, fixes #5)

  Apply fix #1 now? [y/n]
```

## Rules

- Always create at least 3 should-trigger and 3 should-not-trigger scenarios
- Make prompts realistic — include typos, casual language, file paths, context
- Don't make should-not-trigger prompts obviously irrelevant (test near-misses)
- Simple one-step queries won't trigger skills regardless — don't count those as failures
- Save eval sets to `<skill-dir>/evals/` for future regression testing
- Target 85% activation rate — 100% is unrealistic and may indicate over-broad description
- Always end with one concrete fix the user can approve
