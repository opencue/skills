# Skill & MCP Authoring

Adding or improving a skill or MCP is the most common cue contribution. Get the
trigger and the lint gate right and the rest follows.

## Where skills live

```
resources/skills/skills/<category>/<slug>/
  SKILL.md          # the skill itself (frontmatter + body)
  references/       # progressive-disclosure docs, loaded on demand
  evals/evals.json  # optional activation eval scenarios
```

Categories already in use include `meta`, `gstack`, `tools`, `research`,
`review`, `medusa`, and others. Put a cue-about-cue skill under `meta/`.

## Scaffold a new skill

```bash
cue skills-new <name>
# then edit resources/skills/skills/<category>/<name>/SKILL.md
```

The resolver auto-discovers the skill once the file exists; no registration
step.

## The description is the trigger

The `description:` field is what makes Claude activate the skill. Write it as
"Use when the user says X, Y, or Z" with concrete quoted phrases. A skill with a
vague description does not fire. Examples lift activation from about 50% to
about 90%, so include one.

Rules the linter enforces (R001-R008, zero errors required to pass):

- **R001 (error):** frontmatter must have `name:`.
- **R002 (error):** frontmatter must have `description:`.
- **R003 (warning):** `description` should be 200 characters or fewer.
- **R004 (warning):** the description needs a trigger phrase ("Use when ...").
- **R005 (error):** `allowed-tools` must use Anthropic's `Bash(name:*)` /
  `Read(path)` form.
- **R006 (warning):** if the skill declares CLI dependencies, add a
  `## Prerequisites` section.
- **R007 (info):** add `category:` and `tags:` for discoverability.
- **R008 (warning):** no broken in-document anchor links.

Voice (R009) bans em dashes and AI-vocabulary words. Use commas and periods.

## The references/ convention

Push detail out of SKILL.md into `references/*.md` and link to it. This keeps
the skill short (aim under 200 lines) while making the depth available on
demand. cue's dominant convention is a folder named `references/` (not
`resources/`). Link with relative paths, for example
`[build & test](references/build_and_test.md)`.

## Validate before you finish

```bash
cue lint-skill resources/skills/skills/<category>/<slug>/SKILL.md
cue lint-skill <path> --fix     # auto-fix fixable warnings
```

Zero errors is the bar. Aim to clear the easy warnings too (trigger phrase,
tags, an example) for a high score. Never wire an unlinted skill into a profile.

## Adding an MCP

MCP server configs live under `resources/mcps/`. Match the shape of an existing
config in that directory. After adding one, validate any profile that
references it with `cue validate <profile>`.

## Overlap check

Before writing a new skill, search for an existing one that already covers the
job:

```bash
grep -ril "<keyword>" resources/skills/skills --include=SKILL.md
```

If a skill is close, improve it instead of adding a near-duplicate. Overlap
splits activation and confuses discovery.
