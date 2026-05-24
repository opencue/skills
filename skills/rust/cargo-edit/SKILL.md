---
name: cargo-edit
description: Use when adding, removing, or upgrading Rust dependencies, or auditing unused deps. Covers cargo add/rm/upgrade, cargo-outdated, cargo-machete, cargo-udeps.
allowed-tools: Bash(cargo:*), Bash(cargo-edit:*), Bash(cargo-outdated:*), Bash(cargo-machete:*), Bash(cargo-udeps:*)
---

# Cargo Dependency Tooling

Manage Cargo.toml without hand-editing.

## When to use
- Add: `cargo add serde --features derive`
- Remove: `cargo remove serde`
- Upgrade everything compatibly: `cargo update`
- Upgrade past semver: `cargo upgrade` (needs cargo-edit) — bumps Cargo.toml itself
- See what has a newer version: `cargo outdated --root-deps-only`
- Find unused deps (fast): `cargo machete`
- Find unused deps (thorough, needs nightly): `cargo +nightly udeps`

## Prerequisites
- cargo-edit, cargo-outdated, cargo-machete, cargo-udeps

## Notes
- `cargo add/remove` are built into cargo since 1.62, but `cargo upgrade` still needs cargo-edit.
- `cargo machete` is fast and catches the common case; reach for udeps only when machete misses something (it's nightly-only and slower).
- `cargo outdated --root-deps-only` filters out transitives — usually what you want.
