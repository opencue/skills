---
name: cso
description: |
  OWASP Top 10 + STRIDE threat model audit of the current diff (or the
  whole repo on demand). Zero-noise: findings must pass an 8/10+ confidence
  gate AND include a concrete exploit scenario before they're surfaced.
  Use when the user says "security audit", "OWASP review", "threat model",
  "cso", "is this secure", or before shipping anything that touches auth,
  user input, secrets, or payments.
allowed-tools: [Bash, Read, Grep, Glob, Write, AskUserQuestion, WebSearch]
triggers:
  - security audit
  - owasp review
  - threat model
  - cso
  - is this secure
---

# /cso — Chief Security Officer audit

Most "security review" output is noise: speculative findings with no
exploit path, dressed up as critical. This skill flips that — every
finding must clear two gates:

1. **8/10+ confidence** that the finding is real (not "could be" — "is").
2. **A concrete exploit scenario** the user could reproduce on a test
   instance.

Findings that fail either gate are dropped. Better to surface 3 real
issues than 30 hypothetical ones.

## Scope

Ask the user: full-repo audit, or diff vs base branch? Default: diff.

For full-repo: walk the standard high-risk paths first.
- Auth/session handling
- Endpoints accepting user input
- DB query construction
- Secret loading / env var handling
- File upload / download
- External API calls (SSRF)
- Crypto / signing / token verification

For diff: `git diff <base>...HEAD` only.

## Two-lane audit

### Lane 1 — OWASP Top 10 (2021)

For each, check the diff/scope:

| # | Category | Quick test |
|---|---|---|
| A01 | Broken access control | Endpoints checking authn but not authz; IDOR (user_id from request body trusted) |
| A02 | Cryptographic failures | Hardcoded keys, missing TLS, weak hashing (MD5/SHA1 for passwords) |
| A03 | Injection | SQL/NoSQL string interpolation, shell `shell=True`+interpolation, LDAP/XPath injection |
| A04 | Insecure design | Missing rate limiting on sensitive endpoints, predictable IDs, no MFA on admin |
| A05 | Security misconfiguration | Debug mode in prod paths, verbose errors leaking stack traces, default creds |
| A06 | Vulnerable components | Old major-version deps with known CVEs (check package.json / pyproject / Cargo.toml against the lockfile) |
| A07 | Identification & auth failures | Session fixation, missing logout, predictable session IDs, no brute-force protection |
| A08 | Software & data integrity | Unsigned/unchecked downloads, deserialization of untrusted data |
| A09 | Logging & monitoring | Auth/access events logged? Failures logged but not silenced? PII NOT logged? |
| A10 | SSRF | URLs fetched without allowlist, internal IPs reachable via redirect |

### Lane 2 — STRIDE threat model

For each entity in the data-flow diagram (or the modified surface):

| Threat | Question |
|---|---|
| **S**poofing | Can an attacker claim to be someone else? Auth checks where needed? |
| **T**ampering | Can the attacker modify data in transit or at rest? Integrity checks? |
| **R**epudiation | Can an attacker deny an action? Audit log for sensitive ops? |
| **I**nformation disclosure | Does the response leak more than intended? Error stacks, internal IDs, secrets? |
| **D**enial of service | Can an attacker exhaust a resource cheaply? Unbounded loops, no rate limit, no body-size cap? |
| **E**levation of privilege | Can a regular user reach admin paths? Check role/permission on every privileged op |

## Confidence gating

For each potential finding, score:
- **Evidence**: Did you read the actual code? (Required — no "looking at the structure" findings.)
- **Reachability**: Is the vulnerable code on a code path that runs in production?
- **Exploitability**: Can you state the exploit in ≤ 3 sentences?

If you can't hit all three at 8/10, drop the finding.

## Output format

```markdown
# /cso audit — <repo> <date>
Scope: <diff | full-repo>
Method: OWASP Top 10 + STRIDE

## Findings (N)

### 1. <one-line title> — <severity: Critical | High | Medium>
- **OWASP**: A0X — <category>
- **STRIDE**: <one or more>
- **Location**: `src/path:line`
- **Confidence**: <8|9|10>/10
- **Exploit scenario** (≤ 3 sentences):
  1. <step>
  2. <step>
  3. <observed result — the actual bad outcome>
- **Recommended fix**: <one paragraph, code snippet if useful>

### 2. …

## What was checked but is fine
<one short paragraph naming the high-risk areas that came up clean —
gives the user confidence the audit was real, not a checklist tick>

## What was NOT checked
<honest list of skipped areas — e.g. "didn't run dependency CVE scan
because no lockfile in diff">
```

## Anti-patterns

- ❌ Listing every line that *could* be a problem. If you can't write
  the exploit scenario, it's not a finding.
- ❌ Flagging things like "consider adding rate limiting" without
  showing the missing endpoint.
- ❌ Padding the report. Three real findings is a great audit.
- ❌ Skipping the "what was fine" section. The user needs to know
  what's been ruled out.

## After this skill

If findings are present, suggest: "Fix the criticals, then re-run
`/cso` on the diff to verify they're closed."
