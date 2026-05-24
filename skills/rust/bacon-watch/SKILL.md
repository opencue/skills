---
name: bacon-watch
description: Use when iterating on Rust code and wanting auto-rerun on save. Covers bacon (TUI) and cargo-watch (simpler scripted loop).
allowed-tools: Bash(bacon:*), Bash(cargo:*), Bash(cargo-watch:*)
---

# bacon & cargo-watch

Live feedback while you code.

## When to use
- TUI with split panes: `bacon` (defaults to check) · `bacon clippy` · `bacon test`
- Per-project jobs: edit `bacon.toml` to define jobs
- One-shot loop: `cargo watch -x check` · chain: `cargo watch -x check -x test`
- On file change run any cmd: `cargo watch -s "cargo run -- --foo"`

## Prerequisites
- bacon (`cargo install --locked bacon`)
- cargo-watch (`cargo install cargo-watch --locked`)

## Notes
- bacon's TUI handles long output better; cargo-watch is better when you want a one-line scripted loop.
- Bacon's `--headless` mode pipes to stdout — useful inside tmux/editor panes.
- Use bacon for active development; reach for cargo-watch only when you need to compose with non-cargo commands.
