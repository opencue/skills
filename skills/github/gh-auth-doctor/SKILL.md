---
name: gh-auth-doctor
description: >-
  Use when user says "gh auth doctor", "stale token", "gh pr create silently fails", "gx finish hung", "auth blocker", or before `gx branch finish --via-pr`. Diagnoses stale `GH_TOKEN`/`GITHUB_TOKEN` env vars silently overriding `~/.git-credentials` (git push works but every `gh` call fails). Read-only.
---

# Gh Auth Doctor

## When to use

Trigger this skill BEFORE any of:

- `gx branch finish --via-pr --wait-for-merge`
- `gh pr create / merge / view`
- Any automation that calls `gh` from inside an Agent CLI session

Also use REACTIVELY when:

- `gx branch finish` hangs indefinitely (silently polling for a PR that was never created)
- `gh auth status` says "token is no longer valid" but `git fetch origin` works
- A finish flow reports `--cleanup` success but the branch is missing from `origin`
- PR creation appears to succeed but no PR URL is printed

NOT for: GitHub Actions CI debugging (use `gh-fix-ci`), or branch/worktree hygiene (use `gitguardex`).

## The failure mode this skill catches

`gx branch finish --via-pr` uses `gh pr create … || true` and `gh pr view`. When `gh` auth is broken but git push still works (because `~/.git-credentials` has a valid token), the script:

1. Pushes the branch successfully
2. Silently fails `gh pr create` (`|| true` swallows the error)
3. Polls `gh pr view` forever in `--wait-for-merge`
4. Eventually the cleanup phase prunes the worktree and local branch

Result: branch is on origin, no PR exists, local branch deleted, commit only recoverable as a dangling object. The wait loop produces zero output because `gh pr view` returns empty, not an error.

Root cause is almost always: stale `GH_TOKEN` or `GITHUB_TOKEN` env var was rotated server-side, but the local shell still exports the old value. The env var takes precedence over `~/.git-credentials` for `gh`, while `git`'s credential helper (`store`) reads `~/.git-credentials` directly and works fine.

## Quick start

```bash
bash "$(dirname "$0")/scripts/diagnose.sh"
```

The script writes a structured diagnosis to stdout and exits 0 (healthy), 1 (env-stale, store-fresh — the bug above), or 2 (both broken).

## Workflow

1. Run the diagnose script (see Quick start).
2. Read the verdict block. It will be one of:

   - **HEALTHY** — `gh auth status` ok, env-stripped `git ls-remote origin` ok. Proceed.
   - **ENV_STALE_STORE_FRESH** — `gh` fails, but `env -u GH_TOKEN -u GITHUB_TOKEN git ls-remote origin` works. This is the silent-finish-hang bug. Three repair paths:
     - **Refresh both** (recommended for interactive shells): user runs `gh auth login -h github.com --web` — fixes `gh` and rewrites `~/.git-credentials` in one step.
     - **Strip env for one command**: prefix the failing automation with `env -u GH_TOKEN -u GITHUB_TOKEN`. Useful when refresh is not immediately possible.
     - **Unset for the session**: `unset GH_TOKEN GITHUB_TOKEN` in the current shell — only affects this shell, not parent processes that launched it.
   - **BOTH_BROKEN** — neither `gh` nor env-stripped git works. The credential store also needs refreshing. Same fix: `gh auth login -h github.com --web` rewrites both.
   - **UNUSUAL** — `gh` works but env-stripped git does not. Rare; usually a credential-helper config issue. Inspect `git config --get-all credential.helper`.

3. After repair, re-run the diagnose script to confirm HEALTHY before proceeding to the original automation.

## What the script does not do

- Does NOT auto-refresh tokens. Token rotation requires the user to authenticate interactively (security boundary).
- Does NOT modify `~/.git-credentials`, `gh` config, or any env var.
- Does NOT call `gh pr create`, `gh pr view`, or any write operation.
- Does NOT cache its verdict. Each invocation re-checks live state.

## Why this exists

On 2026-05-12 a recodee agent session lost a feature commit because:

- `GITHUB_TOKEN` env was a stale PAT (rotated the previous day, S801)
- `~/.git-credentials` had a fresh token
- `git fetch origin` worked, so `agent-branch-start.sh` succeeded
- `gh auth status` showed "token no longer valid"
- `gx branch finish --via-pr --wait-for-merge` ran 22 minutes silently:
  - Pushed the branch fine
  - `gh pr create || true` failed silently
  - `gh pr view` returned empty in the wait loop
  - `--cleanup` pruned the worktree + local branch before the user noticed
- Commit was only recoverable via `git fsck --no-reflogs --lost-found` filtering for the commit message

Running this skill before `gx branch finish --via-pr` would have caught the env/store divergence in under 2 seconds and prompted refresh, saving ~25 minutes of debugging plus a dangling-commit recovery dance.

## Related

- [[gitguardex]] — for worktree/branch state recovery after the failure does happen
- [[gh-fix-ci]] — for Actions/CI debugging via `gh` (assumes gh auth is healthy)
- [[github]] — general `gh` ops
