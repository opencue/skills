---
name: gh-submodule-publish
description: Create missing GitHub repositories and push a parent repository that tracks app repositories as Git submodules. Use when the user asks to finish publishing locally initialized repos, push a parent repo plus backend/storefront submodules, create repos under an org, recover from invalid `gh auth status` when `gh api user` works, fall back from SSH `Permission denied (publickey)` to `gh` HTTPS auth, handle missing `workflow` token scope for `.github/workflows/*`, or verify remote `main` refs after push.
---

# Gh Submodule Publish

## Overview

Publish an already-initialized parent repo plus one or more submodule repos to GitHub. Preserve the local commits, push submodule repositories before the parent, and finish with remote-ref and clean-tree evidence.

## Workflow

1. Inspect local truth first.

```bash
rtk git status
rtk proxy git submodule status
rtk proxy git remote -v
rtk proxy git -C <submodule> status --short --branch
rtk proxy git -C <submodule> remote -v
```

Record expected commit SHAs from `git submodule status` and parent `git rev-parse --short HEAD`. Do not change commits unless the user asks.

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

Final answer must include repo URLs, pushed branch refs, matching SHAs, any auth fallback used, and remaining risk if any.

## Guardrails

- Do not delete or rewrite local history to make a push work.
- Do not remove workflow files to avoid `workflow` scope; refresh token scope instead.
- Prefer private repo creation unless the user explicitly asks public.
- Push submodule repos first so parent gitlinks resolve remotely.
- If a command fails because of sandboxed network access, rerun with network escalation instead of declaring auth broken.
