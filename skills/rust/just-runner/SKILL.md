---
name: just-runner
description: Use when authoring or running project task recipes — Rust ecosystem's de-facto replacement for Make. Justfile syntax.
allowed-tools: Bash(just:*)
---

# just — sane task runner

Make without the tab/dependency-graph pain. Ubiquitous in Rust repos.

## When to use
- List recipes: `just` or `just --list`
- Run a recipe: `just <name>` · pass args: `just test foo`
- Recipe with deps: `release: test lint` runs test + lint first
- Set vars: `just <var>=val build`
- Project-local: `Justfile` at repo root
- User-local: `~/.justfile` (run with `just -g`)

## Prerequisites
- just (distro pkg preferred — apt/brew/pacman/dnf all have it)

## Notes
- Default shell is `sh` on Unix, `cmd` on Windows. Set `set shell := ["bash", "-uc"]` at the top of the Justfile for portable bash semantics.
- Use `@` prefix to silence the recipe echo (`@cargo test`).
- For Rust projects, common recipes: `check`, `test`, `lint` (= `cargo clippy --all -- -D warnings`), `fmt`, `ci` (= chain of all of the above).
- Don't reinvent: if a `Justfile` exists, run those recipes rather than re-typing cargo flags.
