---
name: cargo-nextest
description: Use when running Rust tests slowly with cargo test, or when CI test time hurts. Drop-in faster runner with better output, retries, and JUnit XML.
allowed-tools: Bash(cargo:*), Bash(cargo-nextest:*)
---

# cargo-nextest

Faster, prettier `cargo test` replacement. ~60% faster on most workspaces.

## When to use
- Default test run: `cargo nextest run`
- Filter: `cargo nextest run <substring>` · by crate: `-p <crate>`
- Retry flaky: `cargo nextest run --retries 2`
- CI JUnit output: `cargo nextest run --profile ci` with `[profile.ci.junit] path = "junit.xml"` in `.config/nextest.toml`
- List without running: `cargo nextest list`

## Prerequisites
- cargo-nextest (`cargo install cargo-nextest --locked`)

## Notes
- Does NOT run doctests — keep `cargo test --doc` in CI alongside nextest.
- Parallelism is per-test, not per-binary, which is the speedup source.
- Stable test IDs make flake tracking easy: `<crate>::<test_path>`.
