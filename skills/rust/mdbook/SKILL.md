---
name: mdbook
description: Use when authoring Rust project documentation as a static site — Rust Book / The Cargo Book / clap docs style.
allowed-tools: Bash(mdbook:*)
---

# mdbook

Markdown → static HTML site. The standard for Rust ecosystem long-form docs.

## When to use
- New book: `mdbook init <dir>` (or in place: `mdbook init`)
- Dev server with live reload: `mdbook serve --open`
- Build: `mdbook build` → outputs to `book/`
- Test code samples in the book compile: `mdbook test`
- Lint links: `mdbook-linkcheck` (separate preprocessor crate)

## Prerequisites
- mdbook

## Notes
- Chapter list lives in `src/SUMMARY.md` — order there controls sidebar order.
- Code fences default to `rust` and get `mdbook test`'ed when language is `rust` (not `rust,ignore`).
- For API-reference style docs, prefer `cargo doc` — mdbook is for prose / tutorials.
- Deploy `book/` directly to GitHub Pages, Netlify, or any static host.
