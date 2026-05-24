---
name: chisel-tool
description: Use when an agent needs precision file edits with minimal token overhead — patch-based, kernel-confined paths. Pointer to the upstream Chisel MCP server.
allowed-tools: Bash(chisel:*)
---

# Chisel — agent-oriented precision file edits

[`ckanthony/Chisel`](https://github.com/ckanthony/Chisel) — Rust-powered MCP server providing token-efficient file operations:

- `patch_apply` — send unified diffs instead of whole files (~20× fewer tokens on large edits)
- `shell_exec` — whitelisted Unix tools (grep/sed/awk/find/cat) the model already knows
- Strict path confinement, symlink-aware root, atomic writes, bearer-token auth, `127.0.0.1`-only by default

## When to use
- Editing large files where rewriting them in full would burn context (>100 lines)
- Multi-file refactors where each touch is a small diff
- Untrusted-input agentic workflows where path confinement matters

## Install
- **MCP-style (recommended)**: download a `.mcpb` bundle from [releases](https://github.com/ckanthony/Chisel/releases/latest)
- **Binary**: `cargo install --git https://github.com/ckanthony/Chisel chisel` (or `cue cli install chisel`)
- **Upstream agent guide**: this profile auto-installs the canonical SKILL.md via `npx skills add ckanthony/Chisel`

## Prerequisites
- `chisel` binary on PATH (or run as a Docker MCP)
- An MCP-aware client (Claude Code, Codex, custom)

## Notes
- This skill is a **pointer**. The detailed agent guide is the upstream `SKILL.md` fetched into the materialized profile by cue's npx mechanism — read that one in preference to this.
- For pure-Rust embedding (no separate process), use `chisel-core` library directly.
- Pairs well with `caveman` (terse-output mode) — both target the same goal: less token bloat per turn.
