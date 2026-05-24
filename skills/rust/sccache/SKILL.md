---
name: sccache
description: Use when Rust cold builds are slow, CI rebuild times hurt, or switching branches forces full recompiles. Drop-in compiler cache.
allowed-tools: Bash(cargo:*), Bash(sccache:*)
---

# sccache

Caches rustc outputs (and gcc/clang). Big wins on CI and branch switching.

## When to use
- One-shot: `RUSTC_WRAPPER=sccache cargo build`
- Persistent (project): `.cargo/config.toml` →
  ```toml
  [build]
  rustc-wrapper = "sccache"
  ```
- Persistent (shell): `export RUSTC_WRAPPER=sccache` in `~/.bashrc` / `~/.zshrc`
- Inspect: `sccache --show-stats`
- Cloud cache backends: `SCCACHE_BUCKET=...` (S3), `SCCACHE_GCS_BUCKET=...`, `SCCACHE_REDIS=...`

## Prerequisites
- sccache (`cargo install sccache --locked` or distro package)

## Notes
- Does NOT help with incremental rebuilds in the same workspace — those already work. Wins are cross-branch and cross-machine (CI).
- Don't enable both sccache and `[profile.dev] incremental = true` cache hits will conflict; sccache works best with incremental disabled in CI.
- Local-only filesystem cache lives in `~/.cache/sccache`.
