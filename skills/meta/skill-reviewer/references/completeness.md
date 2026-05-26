# Completeness scoring for skills

Adapted from gstack's Boil-the-Lake principle. AI makes completeness
cheap. When evaluating a skill or a proposed change, score what's
"boilable" and recommend the complete version when the marginal cost is
minutes rather than days.

## The lake-vs-ocean framing

- **Lake (boilable):** full test coverage for a skill, every trigger
  phrase covered, both should-trigger AND should-not-trigger evals,
  all edge cases in the body, References section for the long tail.
- **Ocean (don't boil):** rewriting an entire profile from scratch,
  multi-week skill-library migration, replacing the lint engine.

Lakes get the complete treatment. Oceans get flagged as out of scope.

## Completeness score (0–10) for a SKILL.md

Use this when reviewing or scaffolding. Score across these axes:

| Axis | 0 | 5 | 10 |
|------|---|---|----|
| **Trigger coverage** | Description has no WHEN clause | WHEN present, 2-3 keywords | 5+ keywords, casual + formal phrasings, 1 boundary |
| **Step concreteness** | Prose only ("consider doing X") | Mix of prose + commands | Every step has a bash block + expected output |
| **Scope discipline** | Tries to do 5+ things | Two adjacent jobs | One job, clearly named |
| **Rules section** | Missing | Present but vague | Concrete dos and don'ts, each explains WHY |
| **Exclusion section** | Missing | "What this does NOT do" present | Excludes the 3 most likely false-positive prompts |
| **Examples** | None | One example | 2+ input/output pairs, including a casual phrasing |
| **References split** | Long tables inline, body >500 lines | Some refs split | Body <300 lines, long tables in references/ |

**Total / 70.** Map to a 0–10 by dividing by 7. Round down.

## When to apply

- During `skill-reviewer` Step 2: score the skill before recommending changes.
- During `description-optimizer` Step 5: track how the rewrite moved the
  completeness needle, not just the activation rate.
- During `skill-eval` Step 7: completeness gap explains many activation
  failures.

## Recommending the lake

When recommending the complete version of an improvement, name it:

> "The lake here is: rewrite description (2 min) + add 2 examples (5 min)
> + add the exclusion section (3 min). Total: ~10 min for CC, would be
> ~half a day for a human. Score goes from 4/10 to 8/10."

When flagging an ocean:

> "Splitting the meta/ category into 5 profile-specific sub-skills is an
> ocean. Out of scope for this session — file as a TODO."
