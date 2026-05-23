---
description: "When user asks about finding, installing, or managing MCP servers via Smithery marketplace, guide them through smithery CLI and cue marketplace commands"
tags: [meta, smithery, mcps, marketplace]
category: meta
version: 1.0.0
requires_mcps: []
---

# Smithery — MCP Marketplace

Smithery is the largest MCP registry (100K+ tools). Use it to discover and connect MCP servers.

## Via cue (recommended)

```bash
cue marketplace search "web search"       # search everything
cue marketplace search-mcps "database"    # MCPs only
cue marketplace install-mcp exa           # install + add to profile
cue marketplace list-mcps                 # show connections
cue marketplace find-tools "search web"   # find tools by intent
```

## Direct Smithery CLI

```bash
smithery mcp search "github"              # search registry
smithery mcp add exa --id exa             # connect (remote)
smithery mcp add <id> --client claude     # add to Claude Desktop
smithery mcp list                         # list connections
smithery mcp remove <id>                  # disconnect
smithery tool list <connection>           # list tools
smithery tool find <connection> "query"   # search tools
smithery tool call <conn> <tool> '{}'     # invoke a tool
smithery auth whoami                      # check auth
```

## Popular MCPs

| ID | Uses | Description |
|---|---|---|
| `exa` | 28K | Web search + page fetching |
| `brave` | 13K | Brave web search |
| `context7` | 11K | Up-to-date library docs |
| `github` | 4K | GitHub repos, issues, PRs |
| `googledrive` | 6K | Google Drive files |
| `jina` | 5K | AI search + read pages |
| `parallel/search` | 6K | High-accuracy web search |
| `Tavily` | 3.8K | AI-optimized web search |
| `docfork/docfork` | 2.5K | Docs from GitHub repos |
| `LinkupPlatform/linkup-mcp-server` | 2.9K | Real-time web search |

## Workflow: Add an MCP to your profile

1. Search: `cue marketplace search-mcps "what you need"`
2. Install: `cue marketplace install-mcp <qualifiedName>`
3. Reload: `/cue-reload` (restarts Claude with new MCP)

## Remote vs Local MCPs

- **Smithery MCPs** run remotely on `server.smithery.ai` — no local process
- **Local MCPs** (in `resources/mcps/`) run on your machine
- Both work in cue profiles; Smithery MCPs need internet

## Tips

- Use `--json` flag for machine-readable output
- `smithery tool call` lets you test MCPs without Claude
- Connect multiple MCPs and search across all with `smithery tool find`
