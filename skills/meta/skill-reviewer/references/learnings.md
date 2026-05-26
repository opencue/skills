# Capture learnings — when, what, how

Adapted from gstack's `gstack-learnings-log`. Cue has its own implementation
at `bin/cue-learnings`. Storage: `~/.cue/projects/<slug>/learnings.jsonl`,
one JSON object per line, append-only.

The point: compound knowledge across sessions. The agent that picks up
this project next month should not re-discover what you just learned.

## When to log

Log when you discover something that would save 5+ minutes for the next
session — yours or another agent's. A good test: *"if I started fresh
tomorrow on this codebase, would knowing this earlier change what I did?"*
If yes, log it.

Concrete examples:

- A trigger phrasing that always fires the wrong skill (`pitfall`)
- A profile that consistently misses one capability (`preference`)
- A CLI quirk that took 20 minutes to figure out (`operational`)
- An architectural decision encoded in the code but not documented (`architecture`)
- A reusable approach that worked unexpectedly well (`pattern`)
- A library or tool that solves a class of problem in this codebase (`tool`)

## When NOT to log

Don't log:

- Obvious facts (the README already says this)
- One-time transient errors (network glitch, CI flake)
- Things derivable from `git log` or `git blame`
- User preferences captured elsewhere (CLAUDE.md, profile persona)
- Speculation that you haven't actually verified

If you can't honestly give the discovery a confidence score ≥6, don't log it.

## How to log

```bash
bin/cue-learnings log \
  --type <pattern|pitfall|preference|architecture|tool|operational> \
  --key <short-kebab-slug-for-grouping> \
  --insight "<one-line description, no newlines>" \
  --confidence 1-10 \
  --source <observed|user-stated|inferred|cross-model> \
  [--files path1,path2,path3]
```

### Type taxonomy

| Type | Use for |
|------|---------|
| `pattern` | A reusable approach that worked. "X is best done by Y." |
| `pitfall` | What NOT to do. "Don't try Z, it fails because W." |
| `preference` | A user-stated or repeatedly-observed preference for this project |
| `architecture` | A structural decision encoded in the code (often invisible to grep) |
| `tool` | A library/framework insight relevant to this codebase |
| `operational` | Project environment, CLI, or workflow knowledge |

### Confidence

| Score | Meaning |
|-------|---------|
| 10 | User explicitly stated, or you verified with a test |
| 8-9 | You observed it in the code AND it makes sense from context |
| 6-7 | You observed it once, hasn't been contradicted, but no test |
| 4-5 | Inferred from patterns, plausible but unverified |
| 1-3 | Speculation. Don't log these. |

### Source

- `observed` — you found it in the code or in repeated behavior
- `user-stated` — user told you directly
- `inferred` — deduction from indirect signals
- `cross-model` — multiple models or reviewers reached the same conclusion

## How to retrieve

At session start (or when starting work in a familiar area):

```bash
bin/cue-learnings search                # list everything, newest first
bin/cue-learnings search "<keyword>"    # filter by key or insight
```

If the project has 5+ learnings logged, scan the top 3 before starting
non-trivial work. Recall is cheap; re-discovery is expensive.

## Schema reference

Each line is a JSON object:

```json
{
  "ts": "2026-05-26T09:39:54Z",
  "slug": "opencue-cue",
  "branch": "main",
  "type": "pattern",
  "key": "gstack-port-sprint",
  "insight": "Iron-contract + capture-learnings can be added as cheap shared footer in 4 meta skills under an hour",
  "confidence": 9,
  "source": "observed",
  "files": ["resources/skills/skills/meta/skill-reviewer/SKILL.md"]
}
```

## Anti-patterns

- **Logging everything.** The file becomes noise. Future you scans the top
  10 entries; if 8 of them are obvious, you stop scanning.
- **Vague insights.** "Be careful with X" tells the next session nothing.
  "X requires a 30s sleep after Y because Z" is useful.
- **Confidence inflation.** If you weren't sure, write 5. Lying produces
  bad downstream decisions.
- **Re-logging the same thing.** Search first. If a matching key exists,
  update the existing learning's confidence instead (manual edit for now;
  versioned schema lands later).
