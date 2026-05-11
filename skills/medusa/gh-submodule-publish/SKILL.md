---
name: gh-submodule-publish
description: >-
  Use when user says "publish submodule", "GitHub submodule", or "Medusa submodule publish"
  and needs submodule publishing guidance. Covers repo state, commits, push, references, and
  validation.
---

# Gh Submodule Publish

## Overview

Publish an already-initialized parent repo plus one or more submodule repos to GitHub. Preserve the local commits, push submodule repositories before the parent, and finish with remote-ref and clean-tree evidence.

## Workflow

1. Inspect local truth first.

```bash
# Always resolve repo root dynamically — repos can move mid-session
PARENT="$(git rev-parse --show-toplevel)"
cd "$PARENT"
rtk git status
rtk proxy git submodule status
rtk proxy git remote -v
cat .gitmodules
rtk proxy git -C <submodule> status --short --branch
rtk proxy git -C <submodule> remote -v
```

Record expected commit SHAs from `git submodule status` and parent `git rev-parse --short HEAD`. Do not change commits unless the user asks.

**1a. Validate `.gitmodules` URLs before any push.** Real-world failure mode: typos like `marva_storefornt` instead of `marva_storefront`, or the wrong owner (e.g. `NagyVikt/...` when the canonical is `Webu-PRO/...`). For each submodule URL in `.gitmodules`:

```bash
# Confirm each declared URL resolves to a real repo
for sm_url in $(git config --file .gitmodules --get-regexp '^submodule\..*\.url$' | awk '{print $2}'); do
  owner_repo="$(echo "$sm_url" | sed -E 's#.*github\.com[/:]([^/]+/[^/.]+).*#\1#')"
  rtk proxy gh repo view "$owner_repo" --json nameWithOwner,url 2>&1 | head -3
done
```

If a URL fails with `Could not resolve to a Repository`, do not assume the repo is missing — first try alternative owners (the user's personal account, the org account, recently-used owners from `gh repo list`). Only after exhausting candidates create a new repo. When the canonical owner differs from `.gitmodules`, fix the URL there, then run:

```bash
rtk proxy git submodule sync         # propagates .gitmodules → .git/modules/*/config
```

Without `submodule sync`, edits to `.gitmodules` look correct on disk but submodule pushes still hit the old URL.

2. Verify GitHub auth by API, not only status.

```bash
rtk gh auth status
rtk proxy gh api user --jq .login
```

If `gh auth status` says the token is invalid but `gh api user --jq .login` succeeds, continue and note the false-negative status. If the API cannot connect in sandbox, retry with network escalation. If the API still fails because auth is invalid, stop and ask for `gh auth login -h github.com`.

3. Create missing repos.

Check first:

```bash
rtk proxy gh repo view <owner>/<repo> --json nameWithOwner,visibility,url
```

If missing, create them, usually private unless the user requested public:

```bash
rtk proxy gh repo create <owner>/<repo> --private
```

For submodules, `gh repo create --source .` may fail because submodules use gitfile indirection. Prefer create-by-name, then push with `git -C`.

4. Push submodules before the parent.

Try configured SSH remote first only if it is already configured:

```bash
rtk proxy git -C <submodule> push -u origin main
```

If SSH fails with `git@github.com: Permission denied (publickey).`, set up the GitHub CLI helper and push HTTPS directly without rewriting remotes unless needed:

```bash
rtk proxy gh auth setup-git
rtk proxy git -C <submodule> push https://github.com/<Owner>/<repo>.git main:main
```

5. Push the parent last.

```bash
rtk proxy git push https://github.com/<Owner>/<parent-repo>.git main:main
```

If GitHub rejects `.github/workflows/*` with missing `workflow` scope, run:

```bash
rtk proxy gh auth refresh -h github.com -s workflow
```

This may require device auth. Give the exact URL and one-time code to the user, wait for completion, then retry the parent push.

6. Verify remote refs and clean local state.

```bash
rtk proxy git ls-remote https://github.com/<Owner>/<parent-repo>.git refs/heads/main
rtk proxy git ls-remote https://github.com/<Owner>/<submodule-repo>.git refs/heads/main
rtk git status
rtk proxy git -C <submodule> status --short --branch
```

**6a. Submodule sync proof (lifted pattern).** Print a small table comparing local submodule HEADs against their remotes — the canonical evidence that the parent's gitlinks are pointing at commits that actually exist upstream:

```bash
for sm in $(git config --file .gitmodules --get-regexp path | awk '{print $2}'); do
  local_head=$(cd "$sm" && git rev-parse HEAD)
  remote_head=$(cd "$sm" && git ls-remote origin refs/heads/main | awk '{print $1}')
  match=$([ "$local_head" = "$remote_head" ] && echo "✓" || echo "✗")
  printf '%-25s local=%.8s  remote=%.8s  %s\n' "$sm" "$local_head" "$remote_head" "$match"
done
```

Every row must show `✓` before the parent commit lands. A `✗` means the submodule's HEAD isn't in the remote — push the submodule first or the parent's gitlink will dangle for anyone cloning recursively.

Final answer must include repo URLs, pushed branch refs, matching SHAs, any auth fallback used, and remaining risk if any.

7. Parent push blocked by an auto-classifier or sandbox?

Some agent harnesses block direct pushes to `main`. If `git push origin main` is denied, **do not invent a workaround** (no `--force`, no temp branch rename). Stage and commit locally, then surface the exact one-liner for the user to paste:

```text
! cd <parent-repo-path> && git push origin main
```

Report: branch ahead-by N, commit SHA, and which command they need to run.

## Guardrails

- Do not delete or rewrite local history to make a push work.
- Do not remove workflow files to avoid `workflow` scope; refresh token scope instead.
- Prefer private repo creation unless the user explicitly asks public.
- Push submodule repos first so parent gitlinks resolve remotely.
- Resolve repo root via `git rev-parse --show-toplevel` at every step. Never assume the path the session started in still exists — repos can be relocated mid-task (Documents/X → Documents/Y), and any hardcoded path will dead-end with `cd: No such file or directory`.
- Validate every URL in `.gitmodules` against `gh repo view` before pushing. A typo (`storefornt`) or wrong owner (`NagyVikt` vs `Webu-PRO`) silently routes the push to the wrong destination — or worse, creates a duplicate empty repo.
- After editing `.gitmodules`, always run `git submodule sync` before any push. The on-disk file change is meaningless to the active push pipeline until sync propagates URLs to `.git/modules/*/config`.
- If a command fails because of sandboxed network access, rerun with network escalation instead of declaring auth broken.
