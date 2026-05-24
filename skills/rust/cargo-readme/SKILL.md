---
name: cargo-readme
description: Use when keeping README.md in sync with lib.rs doc comments — generate the README from `//!` crate-level docs.
allowed-tools: Bash(cargo:*), Bash(cargo-readme:*)
---

# cargo-readme

Single source of truth: write docs in `src/lib.rs`, generate README. No drift between rustdoc and the GitHub front page.

## When to use
- **One-shot**: `cargo readme > README.md`
- **Template** (control title/badges around the generated body): `README.tpl` at repo root; reference with `{{readme}}`
- **CI guard**: `diff <(cargo readme) README.md` — non-zero exit blocks PR if README drifted
- **Workspace**: run per-crate; root README usually stays hand-written

## Prerequisites
- cargo-readme
- Crate-level docs in `src/lib.rs`:
  ```rust
  //! # mylib
  //!
  //! Does the thing.
  //!
  //! ## Example
  //!
  //! ```
  //! mylib::do_thing();
  //! ```
  ```

## Notes
- Code blocks in `//!` docs are tested by `cargo test --doc` — README examples stay correct.
- For published crates, this avoids the classic "README example doesn't compile because the API changed" bug.
- Alternative: `cargo-rdme` (newer, slightly different template style). `cargo-readme` is more entrenched.
- For workspace root READMEs that aren't per-crate, hand-edit and skip this skill.
