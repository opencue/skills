---
name: cargo-flamegraph
description: Use when profiling Rust performance, benchmarking, or analysing binary size. Covers cargo-flamegraph, cargo-criterion, cargo-bloat.
allowed-tools: Bash(cargo:*), Bash(cargo-flamegraph:*), Bash(cargo-criterion:*), Bash(cargo-bloat:*), Bash(perf:*)
---

# Rust Performance Toolkit

CPU profiling, benchmark frontend, binary-size analysis.

## When to use
- Flamegraph of a binary: `cargo flamegraph --release` (opens svg)
- Flamegraph of a test: `cargo flamegraph --test <name>`
- Criterion benches with nicer output: `cargo criterion`
- What takes space in the release binary: `cargo bloat --release --crates`
- Per-function bloat: `cargo bloat --release -n 30`

## Prerequisites
- cargo-flamegraph (`cargo install flamegraph --locked`)
- cargo-criterion, cargo-bloat
- Linux: `linux-tools-common` + `linux-tools-generic` for `perf`. macOS: dtrace (root).

## Notes
- Always profile `--release` — debug builds are useless for perf.
- Add `[profile.release] debug = true` to Cargo.toml so flamegraphs have symbols (doesn't slow runtime, just enlarges the binary).
- Criterion benches need the `criterion` crate as a dev-dep and `[[bench]]` entries with `harness = false`.
