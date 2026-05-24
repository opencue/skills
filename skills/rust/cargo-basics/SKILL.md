---
name: cargo-basics
description: Use when starting, building, running, testing, or generating docs for a Rust crate. Covers cargo new/init/check/build/run/test/doc and workspace scoping.
allowed-tools: Bash(cargo:*), Bash(rustc:*), Bash(rustup:*)
---

# Cargo Basics

Core cargo workflow. Use before reaching for anything fancier.

## When to use
- New crate: `cargo new --bin <name>` or `cargo new --lib <name>`
- Inside an existing source tree: `cargo init`
- Type-check only (fast inner loop): `cargo check`
- Build: `cargo build` (debug) · `cargo build --release` (optimized)
- Run binary: `cargo run` · pass args: `cargo run -- --flag value`
- Test: `cargo test` · filter: `cargo test <substring>` · show prints: `cargo test -- --nocapture`
- Docs: `cargo doc --open --no-deps`
- Workspace member scope: `cargo build -p <member>`
- Pick a toolchain: `cargo +nightly build` · default per project via `rust-toolchain.toml`

## Prerequisites
- rustup (installs cargo, rustc, clippy, rustfmt)

## Notes
- `cargo check` is ~3x faster than `cargo build`. Loop on check, build only when running.
- `--release` strips debug + enables optimizations — slow to compile, much faster runtime. Don't use it for tests unless benchmarking.
- `Cargo.lock` should be committed for binaries, ignored for library crates published to crates.io.
