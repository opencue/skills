---
name: cargo-mutants
description: Use when measuring test quality — mutation testing modifies your code and checks tests catch the change. Finds "I have 90% coverage but tests assert nothing".
allowed-tools: Bash(cargo:*), Bash(cargo-mutants:*)
---

# cargo-mutants — mutation testing

Permutes operators (`<` → `<=`, `+` → `-`, returns `Default`, etc.) then runs your tests. A mutation that survives = your tests aren't really testing it.

## When to use
- **First run**: `cargo mutants` (slow — runs whole test suite per mutation)
- **Scope to one file**: `cargo mutants -f src/parser.rs`
- **Skip slow tests**: `cargo mutants --test-tool=nextest -- --skip slow_`
- **Baseline-only (fast sanity)**: `cargo mutants --check`
- **In CI** (PR-scoped): `cargo mutants --in-diff <(git diff main)`

## Prerequisites
- cargo-mutants
- A passing test suite (baseline must be green or it bails)

## Notes
- Expect long runtimes — N_mutants × test_duration. Practical on libraries (~minutes), painful on large workspaces (hours). Use `--in-diff` in CI.
- "Missed" mutations point to under-tested branches; "timeout" usually means an infinite loop introduced by the mutation (safe).
- Pair with `cargo-nextest` (`--test-tool=nextest`) for big speedups.
- Skip generated code, FFI shims, and trivial newtypes via `# mutants: skip` line comment.
