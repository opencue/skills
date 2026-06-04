# TDD for skills: baseline-first authoring

Ported from `obra/superpowers` (`skills/writing-skills`, 217K★). cue already
scores activation (`skill-eval`) and optimizes triggers (`description-optimizer`).
This adds the missing discipline: prove the skill changes **behavior under
pressure**, not just that it fires.

## Core principle

> If you did not watch an agent fail **without** the skill, you do not know if
> the skill teaches the right thing.

Writing a skill is test-driven development applied to process documentation.
Run the test (a pressure scenario) before you write the skill, watch it fail,
write the minimal skill that fixes the exact failure, watch it pass.

## The RED-GREEN-REFACTOR loop for a skill

| TDD step | Skill authoring |
|---|---|
| Write the test first | Write a pressure scenario a subagent will face |
| Watch it fail (RED) | Run it with **no skill loaded**; record the exact rationalizations the agent uses to dodge the right behavior |
| Minimal code | Write the smallest skill that closes those specific rationalizations |
| Watch it pass (GREEN) | Re-run the same scenario with the skill loaded; confirm the agent complies |
| Refactor | Hunt for *new* loopholes the agent invents, plug them, re-run |

The baseline (RED) is the part teams skip. Without it you are guessing what to
write, and you cannot tell a skill that works from one that just sounds good.

## How to run it in cue

1. **Pick the behavior** the skill must enforce (e.g. "always run the check
   before claiming done").
2. **Scaffold the scenario** with `skill-eval`, but add a *no-skill* baseline
   arm, not only the activation arm. Capture the agent's transcript.
3. **Read the failure**, quote the rationalizations verbatim (these become the
   "Common mistakes" section of the skill).
4. **Write the minimal skill** addressing those exact dodges.
5. **Re-run**; if the agent finds a new escape hatch, that is the next RED.
   Loop until two clean passes.

## What this changes about review

When reviewing a skill, ask: *was there a baseline?* A skill written without
watching a failure first is a hypothesis. Flag it 🟡 and request the RED
transcript, or run one before trusting the skill in a profile.

## Related

- `description` is WHEN, never WHAT. Never summarize the workflow in the
  description (see [decision-brief-format.md](decision-brief-format.md) and the
  description-optimizer skill). superpowers calls this Claude Search Optimization.
- Skills are reusable techniques, **not** narratives of how you solved something
  once. If it only applies to this repo, it belongs in CLAUDE.md, not a skill.
- Close loopholes iteratively. See the REFACTOR row above.
