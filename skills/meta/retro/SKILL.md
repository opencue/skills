---
name: retro
description: |
  Engineering retrospective from git history + cue session log. Per-author
  shipping streaks, test-health trend, growth opportunities, and one
  one-paragraph "what to do differently next week." Saves a markdown file
  under .cue/retros/<YYYY-WW>.md. Use when the user says "weekly retro",
  "what did we ship", "engineering retrospective", or at end-of-sprint.
allowed-tools: [Bash, Read, Write, Glob, AskUserQuestion]
triggers:
  - weekly retro
  - what did we ship
  - engineering retrospective
  - sprint retro
---

# /retro — weekly engineering retro

Reads git history + cue's session log + (optionally) per-author commit
trends, produces a structured retro doc, and (most importantly) writes
**one paragraph** on what to change next week.

## Inputs

1. **Time window.** Default: last 7 days. Ask via `AskUserQuestion` if
   the user wants a different window (last sprint, last month, since
   tag, since date).
2. **Repo set.** Default: cwd repo. If user passes `global`, walk every
   git repo under `~/Documents` (or under `~/.config/cue/recent-repos`
   if that exists) and aggregate.
3. **Authors.** Default: all authors. If the repo has > 1 contributor,
   ask whether to break out per-author.

## Data gathering (read-only)

For each repo in scope:

```bash
git log --since="$WINDOW" --pretty=format:'%H|%an|%ae|%ad|%s' --date=iso \
  > /tmp/retro-commits.txt

git log --since="$WINDOW" --shortstat --pretty=format:'%H|%an' \
  > /tmp/retro-stats.txt

# PRs merged in window (if gh CLI is available and authenticated)
gh pr list --state merged --search "merged:>=$DATE" --json number,title,author,mergedAt 2>/dev/null \
  > /tmp/retro-prs.json || true
```

Pull test-health trend if there's a CI artifact or coverage badge in
the repo — otherwise skip.

Also read `~/.config/cue/session-log.jsonl` (cue's session analytics,
maintained by the `session-summary` hook) and filter to this repo
within the window. Count skill hits, errors, longest sessions.

## Structure of the retro doc

Save to `.cue/retros/<YYYY-WW>.md`:

```markdown
# Retro — week of <YYYY-MM-DD>
*Generated <date> by /retro across <N> repo(s).*

## Headline
<one sentence: the most-important thing that happened this week>

## What shipped
- <date> <repo> <one-line summary, PR # if available>
…

## By author (only if multi-contributor)
### <name>
- Commits: N (+X / -Y lines, M files)
- Top areas: <e.g. "auth, billing">
- Notable: <merged PRs, big refactors, bug fixes>

## Test health
- Tests: <added N, removed M, total now T>
- Coverage trend: <up / flat / down — only if data available>

## cue session signals (last 7d)
- Sessions: N (avg duration <min>)
- Most-used skills: <top 5 with hit counts>
- Errors / blocked hooks: <count, and any pattern>

## What worked
<2–3 bullets, one sentence each. Be specific.>

## What hurt
<2–3 bullets. Same.>

## One thing to change next week
<one paragraph. Concrete. Not "improve testing" — say which test, which
file, which behavior.>
```

## Style notes

- **Be specific.** "Auth flow shipped" beats "made progress on auth."
  Cite PR numbers, file paths, dates.
- **One headline.** Not five. Force a pick.
- **One change.** The "one thing to change next week" section is the
  point of this skill. Make it actionable.
- **Don't make up data.** If `gh pr list` fails, say so and skip the PR
  section. Don't infer.

## After this skill

If a `cue eval` profile exists, suggest running it to compare this
week's signals to last week's. Otherwise stop.
