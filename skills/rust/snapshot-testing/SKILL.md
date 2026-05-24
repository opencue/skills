---
name: snapshot-testing
description: Use when testing CLI output, API responses, rendered templates, error messages — anything where the assertion is "output looks like this big chunk of text". Covers cargo-insta.
allowed-tools: Bash(cargo:*), Bash(cargo-insta:*)
---

# insta — snapshot testing

Saves the first run's output as a `.snap` file; future runs diff against it. Eliminates dozens of brittle `assert_eq!` lines.

## When to use
- **In a test**: `insta::assert_snapshot!(rendered)` (plain text) · `assert_debug_snapshot!(value)` (Debug) · `assert_json_snapshot!(value)` (serde Serialize → JSON)
- **First run + accept**: `cargo insta test --review` — diffs new snaps interactively
- **Auto-accept (CI bootstrap)**: `INSTA_UPDATE=always cargo test`
- **Redactions** (mask non-deterministic fields like timestamps/uuids):
  ```rust
  insta::assert_json_snapshot!(response, { ".id" => "[id]", ".created_at" => "[ts]" });
  ```
- **Inline snapshots** (small values, lives in the test file): `assert_snapshot!(value, @"expected text");`

## Prerequisites
- cargo
- crate: `insta`
- CLI: `cargo-insta` (for `cargo insta review/test`)

## Notes
- Commit `.snap` files. They ARE the assertion.
- `cargo insta review` workflow: run tests → see diffs → press `a` to accept or `r` to reject per snapshot.
- For HTTP API tests, pair with `wiremock`/`mockito` for fixtures and snapshot the response body.
- Don't snapshot wall-clock timestamps or random IDs — redact them or inject a deterministic clock/RNG.
