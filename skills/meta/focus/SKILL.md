---
name: focus
description: 'Use when user says "focus", "which skill", "what skill should I use", "route this", or faces a task in a profile with many loaded skills. Picks the best-fit loaded skill to invoke, fast.'
tags: [meta, routing, skills, focus]
---

# Focus

Pick the right *loaded* skill for the task at hand. When a profile carries dozens of
skills, the cost is decision latency, not capability. Focus narrows the loaded set to the
one skill that fires, so you invoke it instead of freestyling.

Scope: skills already in the active profile. For a skill that is **not** loaded, use
[[smart-loader]] (it reads from disk). For catalog lookup or dedup before writing a new
skill, use [[skill-suggestion]].

## Steps

1. List what is loaded in the active profile:

```bash
cue skills list
```

2. Narrow by intent (fuzzy match across the set):

```bash
cue skills search "<task keywords>"
```

3. Confirm a candidate by the prompts that historically fired it:

```bash
cue skills triggers <skill-id>
```

4. Invoke the top match via the Skill tool. If 2+ fit, name them and pick the most
   specific. If none fits the loaded set, hand off to [[smart-loader]] or say so plainly.

## How to match

- Read each candidate's `description:` trigger phrases against the task intent; the most
  specific wins. A skill that names the exact tool or platform beats a generic one.
- One skill, one job: route to the single best fit, do not chain three skills for one task.
- Prefer a loaded skill over freestyling. Even a 70% fit usually beats raw improvisation,
  because the skill carries the verified recipe.

## Rules

- Only route to skills in the active profile (`cue skills list`). For unloaded skills use
  [[smart-loader]]; this skill never loads from disk.
- Name the match and the reason in one line before invoking, so the choice is auditable.
- If nothing fits, say so and offer [[smart-loader]] or a new skill. Do not force a bad match.
- Recommend only what the task needs: one skill if one fits.

## Example

User: "focus, I need to find EU tenders."

Run `cue skills list` and `cue skills search "tender"`, see `eu-funding/ted-tender-search`
match the intent and tool exactly, and invoke it. If the profile had no tender skill, hand
off to [[smart-loader]] to find one on disk.
