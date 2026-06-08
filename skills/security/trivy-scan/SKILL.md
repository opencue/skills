---
name: trivy-scan
description: |
  Scan the repo for dependency CVEs, leaked secrets, and IaC/Dockerfile
  misconfigs with Trivy, then hard-block HIGH/CRITICAL before a merge.
  Use when the user says "trivy", "vuln scan", "scan dependencies",
  "supply chain scan", "scan for CVEs", or "security scan before merge".
allowed-tools: Bash(Bash:*), Read, Grep, Glob, AskUserQuestion
category: security
tags: [security, supply-chain, vulnerability, gate, trivy]
triggers:
  - trivy
  - vuln scan
  - scan dependencies
  - supply chain scan
  - scan before merge
---

# /trivy-scan: supply-chain vulnerability gate

Trivy (Aqua Security) scans a repo for three classes of problem that
code review misses: known CVEs in your dependency lockfiles, secrets
committed to the tree, and misconfigured IaC/Dockerfiles. This skill is
the **single source of truth** for the pre-merge security gate. The
reviewer (`/code-review-deep`) and the ship gates (`/ship`, `/autoship`)
all invoke it. Run it standalone any time with "trivy" or "vuln scan".

## Iron contract

1. **A HIGH or CRITICAL finding blocks the merge.** No exceptions
   without a logged waiver (see Rules). The gate is the safety, not a
   prompt. Don't merge past a real finding because it's inconvenient.
2. **Every reported finding cites the package + CVE + fixed version.**
   "Trivy found stuff" is not a report. Quote the row.
3. **Never auto-bump a dependency to silence a finding.** Surface the
   fixed version; the user decides whether to upgrade now or waive.

## Prerequisites

`trivy` CLI. Check and install if missing (canonical extracted version:
this skill's `scripts/ensure-trivy.sh`, use it in CI):

```bash
command -v trivy >/dev/null || brew install trivy 2>/dev/null || sudo pacman -S --noconfirm trivy 2>/dev/null || curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/v0.71.0/contrib/install.sh | sh -s -- -b "$HOME/.local/bin"
trivy --version
```

Not in default `apt`/`dnf`, those need the Aqua repo. The script's
installer fallback is cross-distro. Recipe lives in
`resources/cli-recipes.json` under `trivy`.

## The gate, one command

```bash
trivy fs --scanners vuln,secret,misconfig --severity HIGH,CRITICAL --exit-code 1 --no-progress --skip-dirs "**/node_modules" --skip-dirs "**/_cache" --skip-dirs "**/dist" --skip-dirs "**/.next" --skip-dirs "**/vendor" .
```

- **Exit 0** → no HIGH/CRITICAL findings → gate **PASS**, merge may proceed.
- **Exit 1** → at least one HIGH/CRITICAL finding → gate **BLOCK**. Report
  and stop. Do not merge.
- Any other exit (Trivy error, e.g. DB download failure) → treat as
  **BLOCK** and report the error. A scan that didn't run is not a pass.

## Steps

1. **Ensure Trivy is installed** (Prerequisites). If it cannot be
   installed (offline, no network approval), report that the gate could
   not run and **block**. Do not silently skip.

2. **Pick scope.** Default is the whole working tree (`trivy fs … .`),
   which catches issues in unchanged files too, the right default for a
   merge gate. For a fast diff-scoped pass on a huge repo, scan only the
   changed paths:

   ```bash
   CHANGED=$(git diff --name-only origin/main...HEAD | tr '\n' ' ')
   [ -n "$CHANGED" ] && trivy fs --scanners vuln,secret,misconfig --severity HIGH,CRITICAL --exit-code 1 --no-progress $CHANGED
   ```

   When in doubt, scan the whole tree. A transitive CVE in an untouched
   lockfile still ships in the merge.

3. **Run the gate command** and capture the exit code (`echo $?`).

4. **Report findings** in this format, one row per finding (see Example).

5. **On BLOCK**, list each finding's remediation (bump to fixed version,
   remove the secret and rotate it, or fix the misconfig) and stop. Hand
   the merge decision back to the user with the remediation, not a vibe.

## Example

Gate run that blocks a merge:

```
$ trivy fs --scanners vuln,secret,misconfig --severity HIGH,CRITICAL --exit-code 1 .
$ echo $?
1
```

Reported as:

```
[CRITICAL] pkg:lodash@4.17.4 → CVE-2021-23337 (command injection)
           fixed in 4.17.21 · path: package-lock.json
[HIGH]     secret: AWS access key · path: config/deploy.env:12  (ROTATE)
[HIGH]     misconfig: Dockerfile runs as root (DS002) · Dockerfile:1
```

Verdict: **BLOCK**. Bump lodash to 4.17.21, remove + rotate the AWS key,
add a non-root `USER` to the Dockerfile, then re-run the gate.

## Waivers

A finding can be waived only with a justification, never blanket-ignored.
Add the vulnerability ID to `.trivyignore` with a dated comment:

```
# CVE-2024-1234 transitive via build-only dep, not reachable at runtime.
# Waived 2026-06-05 by <user>; revisit when upstream patches.
CVE-2024-1234
```

A `.trivyignore` entry with no comment is a smell, flag it. Secret
findings are **never** waivable: a leaked key is always a stop, and it
must be rotated, not ignored.

## Rules

- HIGH/CRITICAL → merge **blocked**. The exit code is the gate; honor it.
- A scan that errored or didn't run is a **block**, never a silent pass.
- Secret findings always block and require rotation, regardless of any
  severity flag or `.trivyignore` entry.
- Never auto-upgrade a dependency to clear a finding. Surface the fix.
- Waivers live in `.trivyignore` with a dated reason. No bare entries.
- In CI/offline, pre-warm the vuln DB (`trivy fs --download-db-only`) and
  pass `--skip-db-update` so the gate doesn't fail on a network hiccup.
- Don't widen `--severity` to MEDIUM/LOW in the merge gate, that's noise
  that trains people to ignore the gate. Run those on demand only.
