---
name: cargo-audit
description: Use when checking a Rust project for known vulnerabilities, license violations, or supply-chain risk. Covers cargo-audit, cargo-deny, cargo-geiger, cargo-vet, cargo-crev.
allowed-tools: Bash(cargo:*), Bash(cargo-audit:*), Bash(cargo-deny:*), Bash(cargo-geiger:*), Bash(cargo-vet:*), Bash(cargo-crev:*)
---

# Rust Security Suite

Supply-chain and unsafe-code auditing.

## When to use
- Vuln scan against RustSec advisory DB: `cargo audit`
- Hard-fail in CI: `cargo audit --deny warnings`
- Policy check (licenses, advisories, dup versions, bans): `cargo deny init` then `cargo deny check`
- Count unsafe in deps: `cargo geiger`
- Supply-chain trust audit (Mozilla): `cargo vet init` then `cargo vet`
- Crowd-sourced review trust web: `cargo crev review <crate>`

## Prerequisites
- cargo-audit, cargo-deny, cargo-geiger, cargo-vet, cargo-crev (all via `cargo install --locked`)

## Notes
- cargo-audit + cargo-deny together cover 90% of real-world supply-chain needs. Start with those two.
- Wire `cargo audit` into CI as a separate job — advisories drop continuously, so a pinned `Cargo.lock` can become unsafe overnight without a code change.
- cargo-deny config lives in `deny.toml`. Use `[advisories]` and `[licenses]` first; `[bans]` and `[sources]` are advanced.
- cargo-geiger output is informational, not gating — high unsafe counts in crates like `tokio` are expected.
