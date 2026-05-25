# Pre-Landing Review Checklist

## Instructions

Review the `git diff <base-branch>` output for the issues listed below. Be
specific — cite `file:line` and suggest fixes. Skip anything that's fine.
Only flag real problems.

**Two-pass review:**
- **Pass 1 (CRITICAL):** SQL & data safety, race conditions, LLM trust
  boundary, shell injection, enum completeness. Highest severity.
- **Pass 2 (INFORMATIONAL):** Remaining categories below. Lower severity
  but still actioned.
- **Specialist categories (handled by parallel sub-reviews, not this
  checklist):** test gaps, perf, maintainability, api-contract, data
  migration, red-team. See `specialists/`.

All findings get action via fix-first heuristic (below).

**Output format:**

```
Deep Review: N issues (X critical, Y informational)

AUTO-FIXED:
- [file:line] Problem → fix applied

NEEDS INPUT:
- [file:line] Problem description
  Recommended fix: <suggestion>
```

If no issues found: `Deep Review: No issues found.`

Be terse. One line per problem, one line per fix. No "looks good overall."

---

## Pass 1 — CRITICAL

### SQL & data safety
- String interpolation in SQL — even if values are `.to_i`/`.to_f`. Use
  parameterized queries (Rails: `sanitize_sql_array`/Arel; Node: prepared
  statements; Python: parameterized DB-API).
- TOCTOU races: check-then-set patterns that should be atomic `WHERE` +
  `update_all`.
- Bypassing model validations for direct DB writes (Rails: `update_column`;
  Django: `QuerySet.update()`; Prisma raw queries).
- N+1 queries: missing eager loading (`.includes()`, `joinedload()`,
  `include`) for associations used in loops/views.

### Race conditions & concurrency
- Read-check-write without a uniqueness constraint or duplicate-key catch
  (e.g. `where(hash:).first` then `save!`).
- find-or-create without a unique DB index.
- Status transitions that don't use atomic `WHERE old_status = ? UPDATE
  SET new_status` — concurrent updates can skip or double-apply.
- Unsafe HTML rendering on user-controlled data: `.html_safe`/`raw()`,
  `dangerouslySetInnerHTML`, `v-html`, `|safe`/`mark_safe`.

### LLM output trust boundary
- LLM-generated values (emails, URLs, names) written to DB or passed to
  mailers without format validation. Add `EMAIL_REGEXP`, `URI.parse`,
  `.strip` before persisting.
- Structured tool output (arrays/hashes) accepted without type/shape
  checks before DB writes.
- LLM-generated URLs fetched without an allowlist → SSRF risk. Parse
  hostname and check against blocklist before `requests.get`/`httpx.get`.
- LLM output stored in vector DB / KB without sanitization — stored
  prompt-injection risk.

### Shell injection (Python/Node)
- `subprocess.run/call/Popen(..., shell=True)` AND f-string/`.format()`
  interpolation. Use argument arrays.
- `os.system()` with variable interpolation.
- `child_process.exec()` (Node) with template-string interpolation. Use
  `execFile` with an args array.
- `eval()` / `exec()` on LLM-generated code without sandboxing.

### Enum & value completeness
When the diff introduces a new enum value, status string, tier name, or
type constant:
- **Trace it through every consumer.** Read (don't just grep) each file
  that switches on, filters by, or displays it. Common miss: added to the
  frontend dropdown but the backend doesn't persist it.
- **Check allowlists / filter arrays.** Search for arrays containing
  sibling values (e.g. adding `"revise"` to tiers → find every
  `%w[quick lfg mega]` and verify `"revise"` is added where needed).
- **Check `case`/`if-elsif` chains** for fallthrough to the wrong default.

This step requires reading code OUTSIDE the diff.

---

## Pass 2 — INFORMATIONAL

### Async/sync mixing (Python-specific)
- Synchronous `subprocess.run`, `open`, `requests.get` inside `async def`
  — blocks the event loop. Use `asyncio.to_thread`, `aiofiles`, or
  `httpx.AsyncClient`.
- `time.sleep` inside async — use `asyncio.sleep`.
- Sync DB calls in async context without `run_in_executor`.

### Column / field name safety
- Verify column names in ORM queries (`.select`, `.eq`, `.gte`, `.order`)
  against the actual schema — typo'd names silently return empty results
  or throw swallowed errors.
- `.get()` calls on query results must use the column actually selected.

### Dead code & consistency (version/changelog only)
- Version mismatch between PR title and VERSION / CHANGELOG.
- CHANGELOG entries describing changes inaccurately ("changed X to Y"
  where X never existed).

### LLM prompt issues
- 0-indexed lists in prompts (LLMs reliably return 1-indexed).
- Prompt text listing tools/capabilities that don't match the actually-
  wired `tool_classes` / `tools` array.
- Token/word limits stated in multiple places that could drift.

### Completeness gaps
- Shortcut implementations where the complete version is < 30 minutes —
  partial enum handling, incomplete error paths, easily-added edge cases.
- Options presented with only human effort estimates — should show both
  human and AI-assisted time.
- Test coverage gaps where the missing tests mirror happy-path structure.

### Time-window safety
- Date-key lookups that assume "today" covers 24h — a report at 8am PT
  under today's key only sees midnight→8am.
- Mismatched time windows between related features (one hourly, the
  other daily) over the same data.

### Type coercion at boundaries
- Values crossing Ruby↔JSON↔JS where type could change (number vs
  string). Hash/digest inputs must normalize types — `{cores: 8}` vs
  `{cores: "8"}` produce different hashes.

### View / frontend
- Inline `<style>` blocks in partials (re-parsed every render).
- O(n*m) lookups in views (`Array#find` in a loop instead of `index_by`).
- Ruby-side `.select{}` filtering on DB results that could be a `WHERE`.

### Distribution & CI/CD
- Workflow changes (`.github/workflows/`): build-tool versions match
  project requirements, artifact names/paths correct, secrets use
  `${{ secrets.X }}` not hardcoded.
- New artifact types (CLI, library, package): a publish/release workflow
  exists and targets the right platforms.
- Cross-platform: CI matrix covers all target OS/arch (or documents
  which are untested).
- Version-tag format consistency: `v1.2.3` vs `1.2.3` across VERSION,
  git tags, publish scripts.
- Publish-step idempotency: re-running the workflow shouldn't fail
  (`gh release delete` before `gh release create`).

**Don't flag**: web services with existing auto-deploy, internal tools
not externally distributed, test-only CI changes.

---

## Fix-first heuristic

```
AUTO-FIX (no ask):                      ASK (needs human):
├─ Dead code / unused variables         ├─ Security (auth, XSS, injection)
├─ N+1 queries (add eager loading)      ├─ Race conditions
├─ Stale comments contradicting code    ├─ Design decisions
├─ Magic numbers → named constants      ├─ Large fixes (>20 lines)
├─ Missing LLM output validation        ├─ Enum completeness changes
├─ Version/path mismatches              ├─ Removing functionality
├─ Variables assigned but never read    └─ Anything changing user-visible
└─ Inline styles, O(n*m) view lookups      behavior
```

Rule of thumb: if a senior engineer would apply the fix without
discussion → AUTO-FIX. If reasonable engineers could disagree → ASK.

Critical findings default toward ASK. Informational findings default
toward AUTO-FIX.

---

## Suppressions — do NOT flag

- "X is redundant with Y" when the redundancy is harmless and aids
  readability.
- "Add a comment explaining why this threshold was chosen" — thresholds
  drift, comments rot.
- "This assertion could be tighter" when the assertion already covers
  the behavior.
- Consistency-only nits (wrap a value to match how another constant is
  guarded).
- "Regex doesn't handle edge case X" when input is constrained and X
  never occurs in practice.
- Eval threshold changes — tuned empirically.
- Harmless no-ops.
- Anything already addressed elsewhere in the same diff — read the
  full diff before commenting.
