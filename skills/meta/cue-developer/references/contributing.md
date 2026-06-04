# Contributing: Commits, PRs, Common Tasks

## Pull request rules

1. **One concern per PR.** Do not mix a feature with a refactor.
2. **Tests required** for new commands and library functions.
3. **`bun test` green** before submitting; all tests must pass.
4. **Keep the README updated** if you add a user-facing feature.
5. **Profile changes** run `cue validate --all` before the PR.

## Commit messages

Conventional Commits: `type(scope): summary`. Types: `feat`, `fix`, `refactor`,
`docs`, `test`, `chore`, `perf`, `ci`. Keep the subject intent-first; add a body
only when the why is non-obvious. Example:

```
fix(list): render empty skill list instead of throwing
```

## The gated ship flow

Landing completed work is pre-authorized in this repo through a gated flow:
commit, open the PR, run an AI review, and merge only when both hold:

- **Review clean.** No CRITICAL or HIGH finding.
- **No new failures vs base.** The change adds zero failing checks relative to
  the base branch. On a repo with green CI that means green CI.

If a CRITICAL/HIGH finding appears, or a new check fails, stop and report. Do
not merge past the gate.

Still hard stops, never do these: `git push --force`, committing directly on a
protected base, bundling unrelated working-tree changes into the PR, or merging
past a failing gate.

## Draft-PR rule for agents

When an automated agent opens a PR, open it as a draft until a human or the AI
review has looked at it. Keep PR descriptions short: what changed and why. Skip
"how it works" walkthroughs and file-by-file tables; the diff already shows
those.

## Common-task recipes

### Add a CLI command

1. Create `src/commands/my-command.ts` exporting `run(args: string[]): Promise<number>`.
2. Register it in `src/commands/_index.ts`.
3. Add `src/commands/my-command.test.ts`.
4. `bun test` and `bunx tsc --noEmit`.

### Add a dependency

cue keeps a small dependency tree. Confirm the need first, then propose the
`package.json` edit with a one-line rationale and let the maintainer run
`bun add <pkg>`. Never run a global install.

### Add a profile

```bash
cue new <name>          # scaffold profiles/<name>/
# edit profiles/<name>/profile.yaml
cue validate <name>     # or: cue validate --all
```

### Add a skill or MCP

See [skill_and_mcp_authoring.md](skill_and_mcp_authoring.md).

## Script and workflow authoring

Extend an existing script or CI file before adding a new one. Avoid speculative
flags, restated defaults, and silent fallbacks; fail loud with a clear message
when an assumption breaks.
