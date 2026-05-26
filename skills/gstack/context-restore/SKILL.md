---
name: context-restore
description: |
  Resume from a context note saved earlier by /context-save. Loads the most
  recent .cue/context/*.md for the current branch (or asks if multiple match)
  and replays the task, next-step, decisions, and failed-approach lists. Pair
  with /context-save. Use when the user says "resume", "restore context",
  "where was I", or "pick up where I left off".
allowed-tools: [Bash, Read, Glob, Grep, AskUserQuestion]
triggers:
  - resume where i left off
  - restore context
  - where was i
  - pick up where i left off
  - context restore
---

# /context-restore — resume from a saved context note

## Step 1 — find the right note

Look under `.cue/context/`. Match against current branch first:

```bash
branch="$(git branch --show-current 2>/dev/null | tr '/' '-')"
ls -t .cue/context/${branch}-*.md 2>/dev/null | head -3
```

- **One match**: load it.
- **Multiple matches**: ask via `AskUserQuestion` — list the 3 most
  recent with timestamps and one-line "Task" preview from each.
- **No match for current branch**: fall back to the 3 most-recent notes
  across all branches and ask.
- **None at all**: tell the user "no saved context found" and stop.

## Step 2 — read the note

Read the full markdown. Don't summarize it back to the user word-for-word
— they wrote it. Just confirm what you absorbed.

## Step 3 — reconcile against current state

The note was a snapshot. The repo may have moved since:

- Re-run `git status -s`, `git log -5 --oneline`.
- If the branch advanced (new commits since the save), say so explicitly:
  "Note was saved at sha X, branch is now at sha Y (N commits forward)."
- If the working tree differs from what the note expected, flag the
  delta and ask whether to proceed.

## Step 4 — report what you'll do next

In one paragraph, state:

> "Resuming `<task>`. Last action was `<just-done>`. Next step is
> `<next-step>`. I'll avoid `<failed-approaches>`. Sound right?"

Then wait for confirmation before continuing.

## Anti-patterns

- ❌ Loading the note and immediately starting work. The state may have
  moved — confirm with the user first.
- ❌ Reading only the "next step" field. The failed-approaches and
  decisions sections are why the note exists.
- ❌ Picking the newest note across branches when the current branch
  has its own. Branch match wins.

## After restoring

Continue the task. Don't write a fresh `/context-save` yet — that
happens later when the user wants to checkpoint.
