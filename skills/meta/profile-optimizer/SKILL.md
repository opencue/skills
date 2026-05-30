---
name: profile-optimizer
description: >-
  Runs cue optimizer and rank commands, presents visual results, suggests
  removals and additions to slim the active profile. Use when user says
  "optimize profile", "clean up skills", "what skills am I not using",
  "suggest skills for this repo", or "profile review".
tags: [meta, cue, profiles, optimization]
category: meta
version: 1.0.0
requires_mcps: []
allowed-tools: Bash
---

# Profile Optimizer

You help users optimize their cue profile by analyzing skill usage, suggesting removals of unused skills, and recommending new skills based on the current repository.

## Iron contract — never silently mutate a profile

Profile edits are user-visible and affect every future session under that
profile. Never run `cue skills remove`, `cue skills add-to-profile`, or
edit `profile.yaml` without first showing the user the exact diff and
getting explicit approval. The dashboard step is read-only; the mutation
step is gated. A silent removal that breaks the user's next session is
the worst-possible failure mode for this skill.

## When to activate

- User says "optimize my profile", "clean up skills", "profile review"
- User asks "what skills am I not using?"
- User asks "what skills would help in this repo?"
- User says "suggest skills", "recommend skills for this project"

## Step 1 — Show current profile status

Run the optimizer for the active profile:

```bash
cue optimizer $(cat .cue-profile 2>/dev/null || cue current 2>/dev/null | head -1)
```

Present the output to the user. Highlight:
- Total skills count
- MCPs loaded
- Required CLIs

## Step 2 — Show usage ranking

Run the skill usage ranking:

```bash
cue skills rank 50
```

Present a summary to the user:
- **Top 5 most-used skills** — these are essential, keep them
- **Skills with 0 usage** — candidates for removal
- **Skills used <3 times** — low-value, consider removing

## Step 3 — Identify unused skills in the active profile

Cross-reference the profile's skills against the usage data:

```bash
# Get active profile skills
cue skills list 2>/dev/null

# Get usage data
cue skills rank 999 2>/dev/null
```

For each skill in the profile that has 0 usage, present it as a removal candidate.

Format your recommendation like:

```
🧹 Unused skills (candidates for removal):

  ⚠️  skill-name — never used in any session
  ⚠️  another-skill — never used in any session

💡 These skills add to your system prompt budget but haven't been triggered.
   Remove with: cue skills remove-from-profile <category/name>
```

## Step 4 — Recommend skills for the current repo

Analyze the current repository to suggest relevant skills:

```bash
# Detect project type
ls package.json Cargo.toml pyproject.toml go.mod Makefile docker-compose.yml 2>/dev/null
cat package.json 2>/dev/null | head -20
ls -la .github/workflows/ 2>/dev/null
```

Based on what you find, suggest skills from the available pool:

```bash
cue skills available 2>/dev/null | head -40
cue skills search "<relevant-keyword>" 2>/dev/null
```

Format recommendations:

```
💡 Recommended skills for this repo:

  ✅ deployment/coolify — this repo has docker-compose.yml
  ✅ review/security-review — this repo handles auth (found JWT imports)
  ✅ stripe/stripe-webhooks — found @stripe/stripe-node in dependencies

  Add with: cue skills add-to-profile <id>
```

## Step 5 — Present optimization summary

Show a before/after comparison:

```
📊 Profile Optimization Summary
─────────────────────────────────
  Current:  24 skills, 3 MCPs, 12 CLIs
  After:    18 skills, 3 MCPs, 10 CLIs  (−6 unused removed)

  Suggested additions: 3 skills relevant to this repo
  Token budget saved: ~2,400 tokens (from removing 6 unused skills)

  Apply changes? (list the exact commands)
```

## Rules

- **Never auto-remove skills.** Always present as suggestions and let the user decide.
- **Show the commands** the user needs to run — don't run destructive commands yourself.
- **Be concise.** Don't list every skill — focus on the actionable ones (unused + recommended).
- **Consider inheritance.** Skills from `core` profile are shared everywhere — don't suggest removing those.
- **Explain WHY** a skill is recommended (what in the repo triggered the suggestion).

## Capture learnings

If you noticed something about this profile that future-you should know
(a skill that *looks* unused but is actually critical during specific
workflows, a recurring add-recommendation that the user keeps declining,
a project type signal that suggests a different profile entirely), log it:

```bash
bin/cue-learnings log --type preference \
                     --key <profile-name>-<short-slug> \
                     --insight "<one-line description>" \
                     --confidence 1-10 \
                     --source observed
```

Conventions: [../skill-reviewer/references/learnings.md](../skill-reviewer/references/learnings.md).
