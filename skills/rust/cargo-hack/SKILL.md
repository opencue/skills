---
name: cargo-hack
description: Use when a Rust crate has multiple feature flags and you need to verify every combination compiles + tests cleanly. Catches "works on default features only" bugs.
allowed-tools: Bash(cargo:*), Bash(cargo-hack:*)
---

# cargo-hack — feature combo testing

Without it, `cargo test` only covers default features. Feature combinations are silent bombs.

## When to use
- **Check every feature individually**: `cargo hack check --each-feature`
- **Check every subset** (slow but thorough): `cargo hack check --feature-powerset`
- **Skip dev deps from feature analysis**: `--ignore-private`
- **Limit MSRV**: `cargo hack check --rust-version` (pairs with `cargo-msrv`)
- **Exclude expensive features**: `--exclude-features expensive,slow`
- **CI pattern**: `cargo hack --each-feature --no-dev-deps check`

## Prerequisites
- cargo-hack
- A `Cargo.toml` with `[features]` declared

## Notes
- `--feature-powerset` is N² in feature count; for crates with 6+ features, prefer `--each-feature` + manual important combos.
- Catches the classic "`use mod_x::Foo`" inside `#[cfg(feature = "a")]` that breaks when feature `b` isn't enabled.
- Wire into CI as a separate job — it's slower than the main test job but high-signal.
