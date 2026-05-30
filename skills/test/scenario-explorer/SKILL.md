---
name: scenario-explorer
description: 'Generate edge cases and test scenarios by decomposing a feature across 12 dimensions. Use when planning or testing a feature, or when user says "what could go wrong" or "find the edge cases".'
category: test
license: MIT
metadata:
  attribution: "Adapted from claudekit vc:scenario (MIT) for cue"
  version: "1.0.0"
---

# Scenario Explorer

Decompose a feature or code path across 12 dimensions to surface edge cases, risks, and test targets before implementation begins.

## When to use

- Before implementing complex or stateful features
- Before writing tests (it generates the test targets)
- Risk assessment during planning or code review
- API design review, to surface contract edge cases early

## When NOT to use

- Trivial single-line or cosmetic changes
- Already well-tested, stable code with no recent changes
- Pure config changes with no logic paths

## 12 decomposition dimensions

Not all 12 apply to every feature. Mark the relevant ones first, then generate scenarios only for those.

| # | Dimension | What to look for |
|---|-----------|------------------|
| 1 | User types | admin, guest, banned, new, power user, bot/scraper |
| 2 | Input extremes | empty, null, max length, unicode, special chars, injection |
| 3 | Timing | concurrency, race conditions, timeout, slow network, retry storms |
| 4 | Scale | 0 items, 1 item, 1M items, pagination boundary, cursor wrap |
| 5 | State transitions | first use, mid-flow abort, resume after crash, partial completion |
| 6 | Environment | low-end CPU, no JS, screen reader, proxy/VPN, timezone/locale |
| 7 | Error cascades | DB down, API timeout, disk full, OOM, network partition, partial write |
| 8 | Authorization | expired token, wrong role, shared link, CORS, CSRF, privilege escalation |
| 9 | Data integrity | duplicates, orphan references, encoding mismatch, concurrent migration |
| 10 | Integration | webhook replay, API version mismatch, third-party outage, contract drift |
| 11 | Compliance | GDPR deletion, audit logging gap, data retention, PII exposure |
| 12 | Business logic | edge pricing (zero/negative), coupon stacking, refund after partial delivery, tier limits |

## Workflow

1. Read the target file(s) or parse the feature description from the argument.
2. Filter dimensions: mark which of the 12 apply; skip the rest explicitly.
3. Generate 3 to 5 scenarios per relevant dimension.
4. Categorize severity: Critical / High / Medium / Low.
5. Output a structured table (format below).
6. Summarize total scenario count by severity.

Severity: Critical = data loss, security breach, auth bypass, silent corruption. High = broken for a subset of users, data inconsistency. Medium = degraded UX, recoverable error not surfaced. Low = minor visual glitch, non-blocking warning.

## Output format

```
## Scenario Report: [target]

Dimensions analyzed: [list]
Dimensions skipped: [list + reason]

| # | Dimension | Scenario | Severity | Expected behavior |
|---|-----------|----------|----------|-------------------|
| 1 | Input extremes | Empty string for required name field | High | Return 400 with field error |
| 2 | Authorization | Expired JWT on protected route | Critical | Redirect to login, invalidate session |

### Summary
- Critical: N / High: N / Medium: N / Low: N
- Total: N scenarios across X dimensions
```

## Handoff

- Turn scenarios into tests: pass the table to a `test/` skill as input context.
- Feed plan risks: paste Critical/High rows into `plan-eng-review` or `autoplan`.
- Deep persona debate on top risks: feed Critical scenarios to `plan-ceo-review`.

## Example

```
/scenario-explorer src/api/payment.ts
/scenario-explorer "User registration with OAuth providers"
/scenario-explorer src/middleware/auth.ts
/scenario-explorer "Add multi-tenancy to the database layer"
```

Good trigger phrases: "what could go wrong with X", "find the edge cases", "generate test scenarios", "risk assessment for this feature", "edge cases before I build this".
