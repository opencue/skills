---
name: open-code-review
description: >-
  Use when user says "ocr", "open code review", "run ocr", "second opinion review", or wants a review engine independent of Claude's own judgement. Alibaba's hybrid reviewer — deterministic multi-language ruleset (NPE, thread-safety, XSS, SQL injection) plus an LLM agent, line-level comments, workspace/branch-range/commit modes. NOT for a normal Claude diff review — use code-review, or code-review-deep before landing.
---

# Open Code Review (`ocr`)

Apache-2.0 Go CLI from Alibaba. Two things distinguish it from `code-review`:

1. **A deterministic ruleset runs before the LLM.** Findings like NPE,
   thread-safety, XSS and SQL injection come from pattern pipelines, not from a
   model's opinion, so they do not vary run to run.
2. **It can review without any LLM of its own** (delegation mode), which is how
   you should normally use it inside Claude Code — see below.

Use it as a *second engine*, not a replacement. Different engines surface
different findings; `code-review` stays the default for Claude-native review.

## Delegation mode — prefer this

```bash
ocr delegate preview                        # what would be reviewed
ocr delegate rule src/main.go src/handler.go   # rules resolved for these files
```

`ocr` does file selection and rule resolution; **Claude does the reviewing**.
No API key, no separate model, and **the diff never leaves the machine**. This
is the only mode to use on client repositories unless the user has explicitly
approved sending their code to an external endpoint.

## Standalone mode — needs an LLM

Only when the user wants `ocr` to review by itself (e.g. in CI):

```bash
npm install -g @alibaba-group/open-code-review   # provides `ocr`
ocr config provider     # interactive: pick provider, enter key, tests connectivity
ocr config model
```

Then:

```bash
ocr review                                   # staged + unstaged + untracked
ocr review --from main --to feature-branch   # branch range
ocr review --commit abc123                   # single commit
ocr scan                                     # whole files, no git history needed
ocr scan --path internal/agent
```

Long reviews are resumable — sessions survive interruption:

```bash
ocr session list
ocr review --from main --to feature-branch --resume <session-id>
ocr session comments --severity critical,high --json <session-id>
```

The `--json` form is the one to parse when feeding findings into another step.

## Requirements and gotchas

- **Git >= 2.41.** It drives diff generation, code search, and repo operations.
- **Standalone mode sends your diff to the configured endpoint.** Point it at a
  first-party provider, never a third-party proxy. Confirm with the user before
  enabling it on a client repo. Delegation mode avoids this entirely.
- **It is an MCP _client_, not a server.** `ocr` can consume external MCP
  servers to give its agent more tools (issue lookup, internal docs). Do not try
  to register `ocr` itself as an MCP server — there is nothing to register.
- **Pin the version.** cue's marketplace entry pins `v1.8.8`; match that when
  installing so findings stay reproducible.

## Choosing between the review skills

| Situation | Reach for |
| --- | --- |
| Normal review of the working diff | `code-review` |
| Pre-landing, two-pass, highest rigour | `code-review-deep` |
| Independent second engine, deterministic rules | **this skill** |
| Vulnerability-focused audit | `security-review` |

Running this after `code-review` on a risky diff is reasonable. Running it on
every diff is not — it adds latency for findings that mostly overlap.
