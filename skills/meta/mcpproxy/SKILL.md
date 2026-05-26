---
name: mcpproxy
description: Use when the user mentions "mcpproxy", an MCP router/proxy, fronting many MCP servers behind one endpoint, MCP rate-limit or quarantine, or asks how to cut MCP startup cost when running 15+ servers. Points at smart-mcp-proxy/mcpproxy-go and explains how it fits cue's existing MCP materialization.
tags: [meta, mcp, infra]
category: meta
version: 1.0.0
allowed-tools: Bash
---

# mcpproxy

> Go-based MCP proxy / router. Upstream: [smart-mcp-proxy/mcpproxy-go](https://github.com/smart-mcp-proxy/mcpproxy-go).

cue materializes MCPs per profile (`resources/mcps/`). This user runs
~20 MCPs across profiles. mcpproxy sits in front of N upstream MCPs and
exposes a single MCP endpoint to the agent — cuts cold-start cost and
gives one place to apply allowlists and rate limits.

## When to recommend it

- User reports slow Claude Code startup with many MCPs configured.
- User wants a chokepoint to audit or rate-limit MCP traffic.
- User runs the parallel-agents tier — multiple Claude/Codex sessions all
  spinning up their own MCP processes — and wants one shared backend.

## Install

```bash
# Binary install (recommended)
curl -L https://github.com/smart-mcp-proxy/mcpproxy-go/releases/latest/download/mcpproxy-linux-amd64 \
  -o ~/.local/bin/mcpproxy && chmod +x ~/.local/bin/mcpproxy

# Or from source
go install github.com/smart-mcp-proxy/mcpproxy-go/cmd/mcpproxy@latest
```

## Wiring with cue

1. Run mcpproxy with the existing MCP configs as upstreams:
   ```bash
   mcpproxy --config ~/.config/cue/mcpproxy.yaml &
   ```
2. Point `~/.claude.json` at the proxy instead of each upstream MCP
   directly. Keep the per-profile MCP configs in `resources/mcps/` as the
   source of truth — generate `mcpproxy.yaml` from them.
3. Test with `mcp__<proxied>__<tool>` calls. Tool name passthrough is
   1:1 — no renaming.

## When NOT to recommend it

- Single-MCP setup: just call the MCP directly.
- gbrain or any MCP that holds long-lived stateful connections — proxying
  adds a hop and can desync the MCP's parent-watcher (the gbrain wrapper
  uses `kill -0 $parent_pid` to detect agent exit; the proxy is the
  parent, not the agent, so the watcher will mis-time shutdown).

## Rules

- Never proxy gbrain through mcpproxy without first patching the wrapper
  to track the agent PID via env, not parent PID.
- Never enable mcpproxy globally without flipping one project first and
  measuring startup delta. Claim "faster" only with numbers.
- Never store the proxy config in the repo if it contains API tokens —
  put it under `~/.config/cue/` and add a stub `mcpproxy.example.yaml`
  to the repo.
