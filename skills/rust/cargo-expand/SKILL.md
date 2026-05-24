---
name: cargo-expand
description: Use when debugging Rust macros (proc-macros, derive, declarative) — see what code the macro actually generates.
allowed-tools: Bash(cargo:*), Bash(cargo-expand:*)
---

# cargo-expand

See the post-macro source. Indispensable when a derive misbehaves.

## When to use
- Expand whole crate: `cargo expand`
- One module: `cargo expand path::to::module`
- One test: `cargo expand --test <name>`
- Filter to a function/struct: `cargo expand path::to::ItemName`

## Prerequisites
- cargo-expand
- Nightly toolchain (cargo-expand pins one automatically)

## Notes
- Output is full Rust — pipe through `bat -l rust` for highlighting.
- When a `#[derive(Serialize)]` produces weird output, expand and read the generated `impl`. The compiler error suddenly makes sense.
- Don't commit expanded output — it's a debugging tool, not a refactor target.
