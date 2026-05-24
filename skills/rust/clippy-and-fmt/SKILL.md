---
name: clippy-and-fmt
description: Use when linting or formatting Rust code, or when CI complains about style. Covers cargo clippy with -D warnings, cargo fmt --check, and per-crate config files.
allowed-tools: Bash(cargo:*), Bash(rustfmt:*), Bash(clippy:*)
---

# Clippy & rustfmt

The two non-negotiable Rust quality gates.

## When to use
- Format: `cargo fmt` · check only (CI): `cargo fmt --check`
- Lint: `cargo clippy --all-targets --all-features`
- Lint as gate: `cargo clippy --all-targets -- -D warnings` (warnings become errors)
- Fix what's auto-fixable: `cargo clippy --fix --allow-dirty`
- Project config: `rustfmt.toml` for format rules; `clippy.toml` + `#![deny(clippy::pedantic)]` in lib.rs for lint strictness

## Prerequisites
- rustup (installs both via `rustup component add clippy rustfmt`)

## Notes
- Run both before commit. The fmt check is instant; clippy adds ~2x a `cargo check`.
- Don't blanket-allow lints in lib.rs — `#[allow(...)]` at the offending site so the lint stays useful elsewhere.
- The `-D warnings` flag is what most CIs use; matching it locally avoids surprise failures.
- `cargo fmt --check` exits non-zero on diff — perfect for pre-commit hooks.
