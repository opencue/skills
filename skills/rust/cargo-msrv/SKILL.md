---
name: cargo-msrv
description: Use when determining or verifying the minimum supported Rust version (MSRV) of a published crate.
allowed-tools: Bash(cargo:*), Bash(cargo-msrv:*), Bash(rustup:*)
---

# cargo-msrv

Finds the oldest stable Rust that still compiles your crate. Critical for libraries (downstream users may not be on the latest toolchain).

## When to use
- **Discover MSRV**: `cargo msrv find` (binary searches over toolchains)
- **Verify a declared MSRV**: `cargo msrv verify` (reads `rust-version` from Cargo.toml)
- **Set MSRV in Cargo.toml**:
  ```toml
  [package]
  rust-version = "1.75"
  ```
- **List versions tried**: `cargo msrv list`
- **Per-crate in a workspace**: `cargo msrv --path crates/mylib find`

## Prerequisites
- cargo-msrv
- Multiple rustup toolchains (msrv installs them as needed)

## Notes
- Pair with `cargo-hack`'s `--rust-version` flag to gate feature combinations against MSRV in CI.
- MSRV bumps are semver-significant for many crate authors — treat as a minor (sometimes major) bump.
- The `rust-version` field in Cargo.toml is what `cargo verify-project` and the registry check.
- Use `#[cfg(rust_version = "1.80")]`-style cfg only via the `rustversion` crate — there's no built-in cfg for it.
