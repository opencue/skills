---
name: context-save
description: |
  Capture working context — git state, decisions made, remaining work — so a
  future session (after compaction, a restart, or a worktree switch) can resume
  without re-discovering what's in flight. Writes a markdown note under
  .cue/context/<branch>-<YYYYMMDD-HHMM>.md. Pair with /context-restore.
  Use when the user says "save progress", "save state", "context save", or
  "save my work".
allowed-tools: [Bash, Read, Write, Glob, Grep, AskUserQuestion]
triggers:
  - save progress
  - save state
  - save my work
  - context save
---

# /context-save — capture state for later resume

A session-survival snapshot. Designed to be readable by both a human and a
future model session.

## What to capture

1. **Git state**
   - Current branch, upstream, ahead/behind.
   - `git status -s` — staged, unstaged, untracked.
   - Last 5 commits on this branch (`git log -5 --oneline`).
   - If there's an open PR (`gh pr view --json number,title,state,url` —
     skip silently if `gh` is unauthenticated), record number + title + URL.
2. **Working summary** (write this yourself)
   - Task in one sentence.
   - What was just done (1–3 bullets — what changed and why).
   - Next concrete step (one actionable sentence).
   - Decisions made that won't be re-derivable from the diff (1–3 bullets).
   - Failed approaches to avoid next time (1–3 bullets).
3. **Hot paths** — files touched in the last 10 commits or unstaged.
   List as `<path> — <one-line role>`.
4. **Verification status** — tests / lint / build = pass / fail / not run.

## Output path

`.cue/context/<branch>-<YYYYMMDD-HHMM>.md`. Create the directory if missing.
Replace `/` in branch name with `-` for filesystem safety.

## Template

```markdown
# Context save — <branch> @ <YYYY-MM-DD HH:MM>

## Git
- Branch: <name>, upstream: <name or "none">, <X> ahead / <Y> behind
- Working tree:
  - <file> — <staged|unstaged|untracked>
- Last commits:
  - <sha> <subject>
- PR: #<num> <title> (<state>) — <url>   <!-- if any -->

## Task
<one sentence>

## Just done
- <bullet>

## Next step
<one sentence, actionable>

## Decisions (not derivable from the diff)
- <bullet>

## Failed approaches — don't repeat
- <bullet>

## Hot paths
- <path> — <role>

## Verification
- Tests: <pass | fail | not run>
- Lint:  <pass | fail | not run>
- Build: <pass | fail | not run>
```

## After saving

Tell the user: "Saved to `<path>`. Resume later with `/context-restore`."

## Anti-patterns

- ❌ Saving "I worked on stuff." Be specific — paths, sha, decision.
- ❌ Skipping the failed-approaches section. Highest-value field for the
  next session.
- ❌ Re-saving when nothing meaningful changed. Tell the user "no material
  change since last save at <path>" instead.
