---
name: release-plz
description: Use when automating crates.io releases for a workspace — version bumps, CHANGELOG generation, GitHub Release PRs based on Conventional Commits.
allowed-tools: Bash(cargo:*), Bash(release-plz:*), Bash(git:*), Bash(gh:*)
---

# release-plz — automated release PRs

Reads Conventional Commits, bumps versions, generates CHANGELOG.md, opens a release PR. Merge → publishes to crates.io and tags GitHub release.

## When to use
- **One-time setup**: install + run `release-plz init` at the workspace root
- **Manual local dry-run**: `release-plz update` (writes Cargo.toml + CHANGELOG.md changes, no push)
- **GitHub Actions** (the typical path): drop the official workflow at `.github/workflows/release-plz.yml` — needs `CARGO_REGISTRY_TOKEN` secret + a PAT with PR/contents write
- **Per-crate config**: `release-plz.toml` to tweak version bumps, changelog body templates, dependency-update strategy
- **Skip a crate**: `[[package]] name = "internal" release = false`

## Prerequisites
- release-plz CLI
- Conventional Commit messages (`feat:`, `fix:`, `chore:`, breaking via `!:` or footer `BREAKING CHANGE:`)
- crates.io account + token

## Notes
- Replaces `cargo-release` for most workspaces. `cargo-release` is still useful for hand-curated releases.
- Generated PRs are idempotent — push more commits, the PR updates.
- For pre-1.0 crates, configure `[workspace] semver-check = false` in release-plz.toml to allow breaking bumps without yanking 1.x rules.
- Combine with the `commit-message-guard` hook in cue's core profile to enforce Conventional Commits.
