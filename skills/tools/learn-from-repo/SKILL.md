---
name: learn-from-repo
description: Use when the user says "learn from <repo>", "study how X does Y", or wants to develop cue based on another codebase. Fetches source via opensrc and mines it for reusable patterns to adopt into cue.
allowed-tools: Bash(opensrc:*), Bash(gh:*), Bash(rg:*), Bash(find:*), Bash(git:*), Bash(bin/cue-learnings:*), Read, Write, Glob, Grep
category: tools
tags: [tools, research, source-fetching, patterns, cue-dev]
metadata:
  version: 1.0.0
  homepage: https://opensrc.sh
---

# Learn from a Repo

Fetch another project's source with `opensrc`, read the parts that matter, and
write down the patterns worth bringing into cue. The lens is always "what can
cue adopt from this," not "document this repo." That lens is the skill's reason
to exist: a general code reader explains a repo to you; this one filters every
file through a single question and ends with a capture step that feeds cue
development.

This skill is the workflow layer on top of two primitives: the [opensrc](../opensrc/SKILL.md)
CLI does the fetch, `bin/cue-learnings` captures the durable takeaway.

## Example

User: "learn from vercel-labs/opensrc, how does it cache fetched source? Could
cue's runtime materialization reuse that?"

```bash
REPO=$(opensrc path vercel-labs/opensrc)
rg -n "cache|OPENSRC_HOME|fn store" "$REPO"/packages/opensrc/cli/src | head
```

You read the cache files, then write one finding through the cue lens:
"opensrc keys its cache by `pkg@version` (cache.rs:80-86) and short-circuits on
a match (fetcher.rs:37-50); cue's runtime already does this with a stronger
sha256 content-hash (runtime-materializer.ts:82-134), so this is note-only, not
a port." Then `bin/cue-learnings log` it and recommend (here: do nothing).

## When to activate

- User says "learn from <repo>", "study how X handles Y", "what can we borrow
  from <package>", or "develop cue based on <codebase>".
- User pastes a repo URL or `owner/repo` and asks how it solves a problem cue
  also has.
- Before designing a cue feature that a well-known project already solved, to
  port a proven approach instead of writing net-new code.

## Prerequisites

The `opensrc` CLI must be installed (it ships with the cue core profile):

```bash
opensrc --version || npm install -g opensrc
```

## Step 1: Fetch the source

Pull the repo or dependency. `opensrc path` prints the cached absolute path to
stdout (progress goes to stderr), so it composes in subshells.

```bash
# GitHub repo, optionally pinned to a tag or branch
REPO=$(opensrc path vercel-labs/opensrc)
# or a published package
REPO=$(opensrc path zod)
REPO=$(opensrc path pypi:requests)
REPO=$(opensrc path crates:serde)

echo "$REPO"   # confirm the path resolved
```

If `opensrc` reports `Repository "owner/repo" not found on GitHub`, the
`owner/repo` path was a guess (a project's npm name, author handle, or org
often differs from its repo slug). Don't retry blindly. Look up the real path,
then fetch that:

```bash
gh search repos <name> --limit 8 --json fullName,description,stargazersCount
# pick the matching fullName, then:
REPO=$(opensrc path <owner>/<repo>)
```

Pin a version when the lesson is version-specific:

```bash
opensrc path owner/repo@v1.2.0
opensrc path owner/repo#main
```

## Step 2: Map the structure before reading

Get the shape first so you read the right files, not every file.

```bash
find "$REPO" -maxdepth 2 -not -path '*/.git/*' | head -40  # top-level layout
rg --files "$REPO" -g '*.md' | head                        # READMEs, docs, ADRs
rg -l "TODO|FIXME|HACK" "$REPO" | head                     # known rough edges
git -C "$REPO" log --oneline -15 2>/dev/null               # recent direction, if a repo
```

`find` and `rg` are always present; `fd` is not installed on every machine, so
the map step would silently return nothing if you reached for it.

Read the entry points and the one or two files that own the behavior you came
for. Resist reading the whole tree.

## Step 3: Extract through the cue lens

For each pattern you find, answer four questions. Skip anything that fails the
first one.

1. **Is this relevant to cue?** (profile resolution, skill loading, MCP wiring,
   CLI ergonomics, caching, materialization). If no, drop it.
2. **What exactly do they do?** Cite `file:line` from the fetched source.
3. **Why is it better than what cue does today?** Name the concrete win.
4. **What would porting it cost?** Rough CC-time and human-time.

```bash
# Example: how does opensrc itself resolve + cache versions?
rg -n "fn resolve|cache|lockfile" "$REPO"/packages/opensrc/cli/src | head -20
```

Drop a pattern the moment it fails question 1. A long list of irrelevant
observations is worse than three that cue can act on.

## Step 4: Capture the findings

Capture findings in three places so each study compounds instead of evaporating:

1. **Per-repo note** at `docs/research/learned/<owner>-<repo>.md`, holding per
   pattern: source `file:line`, the win, and the port cost.

   ```bash
   mkdir -p docs/research/learned
   ```

2. **Index row** appended to `docs/research/learned/README.md` so the next
   session sees what's already been studied before re-fetching. One row:
   `| [owner/repo](./<owner>-<repo>.md) | <date> | <question> | <verdict> |`

3. **Durable takeaway** logged for any actionable finding:

   ```bash
   bin/cue-learnings log --type pattern \
     --key learn-<repo>-<short-slug> \
     --insight "<one-line: what cue should adopt and why>" \
     --confidence 1-10 --source observed
   ```

End with a one-line recommendation: adopt now, spike first, or note-only.

Before fetching in Step 1, skim the index to skip repos already studied:

```bash
rg -i "<owner>/<repo>" docs/research/learned/README.md && echo "already studied"
```

## Rules

- Always pin a version (`@tag`/`#branch`) when the lesson depends on it, so the
  source matches what you cite.
- Every claimed pattern cites `file:line` from the fetched source. No citation,
  no claim, downgrade it to a question.
- Filter through the cue lens (Step 3, question 1) before writing anything down.
  This skill studies repos *to develop cue*, not to document them.
- Don't fetch when types or docs already answer the question. A clone costs
  disk and time. Use plain [opensrc](../opensrc/SKILL.md) for one-off lookups;
  use this skill only when the goal is extracting patterns into cue.
- Clean the cache when disk matters: `opensrc remove <pkg>` or `opensrc clean`.
- Don't port code blind. Output a recommendation (adopt / spike / note-only),
  never an unrequested rewrite of cue internals.
