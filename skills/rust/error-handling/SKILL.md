---
name: error-handling
description: Use when designing Rust error types — choosing between thiserror (libraries) and anyhow (apps), wrapping foreign errors, returning Result from main.
allowed-tools: Bash(cargo:*)
---

# Rust Error Handling

Pick the right tool for the layer.

## When to use
- **Library crate**: define a typed error with `thiserror::Error` — callers should be able to `match` on variants.
  ```rust
  #[derive(thiserror::Error, Debug)]
  pub enum MyError {
      #[error("io: {0}")]    Io(#[from] std::io::Error),
      #[error("bad input")]  BadInput,
  }
  ```
- **Binary / app**: use `anyhow::Result<T>` for fast prototyping and `.context("doing X")` to add breadcrumbs.
- **main**: return `anyhow::Result<()>` so `?` works at the top level — exit code becomes 1 on Err with a stderr trace.
- **Propagate, don't `.unwrap()`**: use `?`. Reserve `.unwrap()` / `.expect("invariant: ...")` for things that genuinely cannot happen.
- **Convert across layers**: `#[from]` in thiserror auto-implements `From`, so `?` upcasts without a `.map_err()`.

## Prerequisites
- cargo
- crates: `thiserror`, `anyhow` (add via `cargo add`)

## Notes
- Don't expose anyhow in a library's public API — it erases type info and hurts downstream `match`-ability. Wrap with thiserror at the boundary.
- `.expect()` messages should describe the broken invariant ("config loaded before this call"), not just restate the operation.
- `Result<T, Box<dyn Error + Send + Sync>>` is the stdlib alternative to anyhow when you don't want a dep.
