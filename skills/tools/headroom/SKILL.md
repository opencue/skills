---
name: headroom
description: Compress everything an AI agent reads — tool outputs, logs, files, RAG chunks, conversation history — before it reaches the model, for 60–95% fewer tokens with the same answers. Use when the user says "compress context", "reduce tokens", "headroom", "wrap claude with headroom", "cut my token usage", or wants reversible context compression via library, proxy, or MCP tools (headroom_compress / headroom_retrieve / headroom_stats).
allowed-tools: Bash(headroom:*), Bash(pip:*), Bash(pipx:*)
category: tools
tags: [tools, context-compression, tokens, mcp, proxy, claude-code]
metadata:
  version: 1.0.0
  homepage: https://headroom-docs.vercel.app/docs
  repository: https://github.com/chopratejas/headroom
  package: headroom-ai
---

# Context compression with Headroom

Headroom is a local-first context-compression layer for AI agents. It compresses
tool outputs, logs, files, RAG chunks, and conversation history before they reach
the LLM — same answers, 60–95% fewer tokens. Compression is **reversible** (CCR:
Compress-Cache-Retrieve), so the model can pull the original back on demand.

It ships four ways, all sharing one compression pipeline:

- **Library** — `compress(messages)` in Python or TypeScript (`headroom-ai`)
- **Proxy** — `headroom proxy --port 8787`, zero code changes, any language
- **Agent wrap** — `headroom wrap claude` routes all of Claude Code's traffic through the proxy
- **MCP server** — `headroom_compress` / `headroom_retrieve` / `headroom_stats` for any MCP host

## Prerequisites

Install the CLI once (Python 3.10+):

```bash
pip install "headroom-ai[all]"      # everything
pip install "headroom-ai[mcp]"      # just the MCP server tools
pipx install --python python3.13 "headroom-ai[all]"   # isolated
```

Verify with `headroom --version`.

> TLS `CERTIFICATE_VERIFY_FAILED` on install usually means a corporate proxy is
> intercepting the Rust build fetch. Install Rust first (`rustup default stable`)
> or use a prebuilt wheel: `pip install --only-binary headroom-ai headroom-ai`.

## MCP tools (no proxy required)

Register the MCP server into detected coding agents, then use the tools:

```bash
headroom mcp install          # auto-detect Claude Code / Codex / Cursor and wire the MCP
headroom mcp serve            # start the stdio MCP server (what cue's registry runs)
headroom mcp status           # health check
```

- `headroom_compress` — compress a context blob (auto-routes by content type:
  JSON → SmartCrusher, code → AST via tree-sitter, prose → Kompress-base).
- `headroom_retrieve` — fetch the original uncompressed content for a prior
  compression. Compression never destroys data.
- `headroom_stats` — token-savings + compression observability for the session.

In cue, the `headroom` MCP id is registered in the sanitized registry as
`headroom mcp serve`; add it to a profile's `mcps:` list (the `headroom` profile
and `core` already do).

## Full wrap — compress all Claude traffic

```bash
headroom wrap claude                 # launches Claude through the local proxy
headroom wrap claude --memory --code-graph
```

`wrap` starts a local `headroom proxy` and sets `ANTHROPIC_BASE_URL=http://127.0.0.1:8787`
so every request is compressed before it leaves the machine. Equivalent manual form:

```bash
headroom proxy --port 8787 &
ANTHROPIC_BASE_URL=http://127.0.0.1:8787 claude
```

> **Caveat for global wraps:** if `ANTHROPIC_BASE_URL` points at the proxy but the
> proxy is **not** running, Claude cannot reach Anthropic at all (connection
> refused). For an always-on global wrap, run the proxy as a persistent service
> and health-gate the base URL. cue surfaces `ANTHROPIC_BASE_URL` from `profile.env`
> only through its allowlist, so the wrap is opt-in per profile, not silent.

## Failure learning

```bash
headroom learn                       # mine failed sessions → write corrections to CLAUDE.md / AGENTS.md
```

## When to use

- Long tool outputs / logs / RAG dumps blowing the context budget.
- You want token savings without changing app code (proxy or wrap).
- Cross-agent shared memory between Claude, Codex, and Gemini.

## Rules

- Prefer the **MCP tools** for targeted, in-conversation compression; prefer the
  **wrap/proxy** for transparent whole-session savings.
- Don't point a profile's `ANTHROPIC_BASE_URL` at the proxy unless the proxy is
  guaranteed up — a dead proxy bricks all Claude calls for that profile.
- Compression is reversible: when a compressed view looks lossy, call
  `headroom_retrieve` for the original instead of guessing.
- Data stays local; set `HEADROOM_TELEMETRY=off` to disable anonymous telemetry.
