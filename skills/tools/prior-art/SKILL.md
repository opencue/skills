---
name: prior-art
description: Use when about to build a feature, before writing code. Searches open-source prior art so we don't reinvent what exists. Triggers on "before I build X", "is there an existing X", "find prior art".
allowed-tools: Bash(gh:*), Bash(opensrc:*), Bash(npm:*), Bash(rg:*), Bash(find:*), Read, Write, Glob, Grep
category: tools
tags: [tools, research, reuse, prior-art, dependencies]
metadata:
  version: 1.0.0
  homepage: https://opensrc.sh
---

# Prior-Art Scout

Before building a feature, find out whether someone already built it. This
skill runs the "Research & Reuse" step from `development-workflow.md`: search
GitHub and the package registries for existing solutions, rank them, and only
write net-new code when nothing fits. The reason it exists: most coding flows
jump straight to implementation. This one forces a prior-art pass first and
ends with a build-vs-adopt verdict, so cue ports a proven approach instead of
reinventing one.

It is the discovery front-end for [learn-from-repo](../learn-from-repo/SKILL.md):
this skill finds and ranks candidates; that one does the deep study of the
winner. opensrc caches fetched source globally at `~/.opensrc`, so a repo
pulled once is reachable by path from every project you open, no per-project
copy needed.

## Prerequisites

- `gh` (GitHub CLI, authenticated) for repo and code search
- `opensrc` for fetching the chosen source (ships with the cue core profile):
  `opensrc --version || npm install -g opensrc`
- `npm` for `npm search` / installing an adopted package (or `pip` / `cargo`)

## Example

User: "let's build a retry-with-backoff wrapper for our API calls."

```bash
NEED="retry with exponential backoff http client"
gh search repos "$NEED" --limit 10 \
  --json fullName,description,stargazersCount,license,updatedAt
```

You find `tim-kos/node-retry` (MIT, maintained) and `p-retry` (MIT). You stop,
present both with fit % and verdict "adopt p-retry, don't build", and wait. The
net-new wrapper never gets written because prior art covered it.

## When to activate

- Before implementing a feature: "let's build X", "add a Y", "I need to write
  a Z". Pause and scout first.
- User says "is there an open-source X already", "find prior art for", "has
  someone solved this", "don't reinvent this".
- Any task where adopting or porting a proven library beats hand-rolling.

## Step 1: State the capability in one line

Write down exactly what you are about to build, in one sentence. This is the
search query and the fit yardstick.

```bash
NEED="rate-limited job queue with retries for node"
echo "$NEED"
```

## Step 2: Search prior art across layers

Search widest-net first. Capture stars, license, and last-update so Step 3 can
rank without re-fetching.

```bash
# GitHub repos (ranked by stars), with the fields ranking needs
gh search repos "$NEED" --limit 10 \
  --json fullName,description,stargazersCount,license,updatedAt

# Code-level matches (finds patterns inside repos, not just repo names)
gh search code "$NEED" --limit 10 2>/dev/null

# Package registries — prefer a battle-tested package over a raw repo
npm search "$NEED" 2>/dev/null | head
# pip: `pip index versions <guess>`  crates: browse https://crates.io/search?q=
```

If the first queries miss, reword `NEED` with the core noun only (drop the
adjectives) and run again.

## Step 3: Score the candidates

For each candidate, record four signals. Drop anything that fails the license
gate: an unusable license makes stars irrelevant.

1. **Fit**: what fraction of `NEED` does it cover? (rough %)
2. **License**: permissive (MIT/Apache/BSD) and compatible with cue's
   Apache-2.0? If GPL/none/unclear, it's reference-only, not adopt.
3. **Maintenance**: `updatedAt` within ~12 months and meaningful stars?
4. **Verdict**: adopt (use as dependency) / port (copy the approach) / wrap /
   build-net-new (nothing fits).

## Step 4: Suggest the top candidates

Present the best 2-3 to the user as a short table: repo, stars, license, fit %,
and your verdict. Lead with a recommendation. Do not pull or implement yet.
Wait for the user to pick.

```
| Repo | ★ | License | Fit | Verdict |
|------|---|---------|-----|---------|
| owner/repo | 4.2k | MIT | ~80% | adopt — covers retries + rate-limit |
| owner/other | 900 | Apache | ~50% | port — good backoff, wrong queue model |
Recommendation: adopt owner/repo as a dependency; nothing in cue needs the
net-new build.
```

## Step 5: Pull the winner and learn from it

Once the user picks a repo to study or port, fetch it and hand off to
[learn-from-repo](../learn-from-repo/SKILL.md) Steps 3-4 (extract through the
cue lens, capture findings, log the takeaway).

```bash
REPO=$(opensrc path <owner>/<repo>)   # global cache; reachable from any project
echo "$REPO"
```

If the verdict was **adopt** (use as a dependency), install the package in the
current project instead of porting code:

```bash
npm install <package>     # or: pip install / cargo add
```

## Rules

- License gate is mandatory before any adopt/port. Permissive and
  Apache-2.0-compatible, or it is reference-only. State the license you found.
- Prefer a maintained package over copying repo source. Adopt beats port beats
  build-net-new, in that order, whenever fit allows.
- Search before you suggest, suggest before you pull, pull before you build.
  Never skip to implementation when prior art is likely.
- Don't vendor copies into each project. opensrc's global cache is reachable by
  path from every project; copy in only when offline use or local edits demand
  it, and gitignore it if you do.
- Hand the deep study to [learn-from-repo](../learn-from-repo/SKILL.md); this
  skill stops at the build-vs-adopt verdict and the pull.
