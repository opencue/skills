---
name: typos-spellcheck
description: Use when spell-checking Rust source, docs, comments — `typos` CLI catches common misspellings without false positives on code identifiers.
allowed-tools: Bash(typos:*)
---

# typos — source-code spellcheck

Fast (Rust-written, walks ignoring `.gitignore` + `target/`), accurate (curated dict + identifier-aware).

## When to use
- **Check current dir**: `typos`
- **Auto-fix**: `typos --write-changes` (or `-w`)
- **Specific files**: `typos src/lib.rs README.md`
- **Diff-only** (CI on PRs): `typos --diff`
- **Config file** (`typos.toml` or `_typos.toml` at repo root):
  ```toml
  [default.extend-words]
  abbrv = "abbrv"          # allow this spelling
  [files]
  extend-exclude = ["vendored/**", "*.snap"]
  ```

## Prerequisites
- typos (`cargo install typos-cli --locked` or distro pkg)

## Notes
- Default dict is curated — false-positive rate is genuinely low. Add false positives to `extend-words` rather than disabling.
- Use `# typos: ignore line` (or `// typos: ignore line`) to silence one occurrence.
- Wire as both a pre-commit hook and a CI job; the auto-fix output makes it cheap to keep clean.
- For prose-only checks (style, grammar), reach for `vale` instead — typos is intentionally narrow.
