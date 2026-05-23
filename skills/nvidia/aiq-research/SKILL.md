---
description: "When user asks for deep research, multi-source synthesis, regulatory analysis, or enterprise document research, route through AI-Q server for structured reports with citations"
tags: [research, nvidia, aiq, deep-research, enterprise]
category: nvidia
version: 2.0.0
requires_mcps: []
allowed-tools: Bash(python3:*)
---

# AI-Q Deep Research

Route deep research tasks through NVIDIA AI-Q server for structured, cited reports.

## When to use

- User asks for research across multiple sources
- "Research the regulatory landscape for X"
- "Produce a memo on Y with citations"
- "Synthesize findings from our docs about Z"
- Any task requiring multi-source synthesis with attribution

## Prerequisites

- Python 3.10+
- Running AI-Q server (default: `http://localhost:8000`, override with `AIQ_SERVER_URL`)

## Usage

```bash
python3 scripts/aiq.py research "your research query here"
python3 scripts/aiq.py status <job-id>
python3 scripts/aiq.py result <job-id>
```

## How it works

1. Submit research query → AI-Q classifies intent depth
2. Shallow queries → quick lookup, immediate response
3. Deep queries → multi-stage pipeline:
   - Intent classification
   - Human-in-the-loop clarification (if ambiguous)
   - Multi-source retrieval via MCP servers
   - Synthesis with Nemotron reasoning models
   - Cited report generation

## Integration with cue

AI-Q connects to enterprise data via MCP servers. Configure in your AI-Q blueprint:

```yaml
function_groups:
  mcp_tools:
    _type: mcp_client
    server:
      transport: streamable-http
      url: ${MCP_SERVER_URL:-http://localhost:9901/mcp}
```

## MCP Auth patterns

| Scenario | Pattern |
|----------|---------|
| No auth | `mcp_client` function group |
| Service account | `mcp_client` + `mcp_service_account` |
| User token forwarding | Custom tool with `get_auth_token()` |

## Output format

Reports include:
- Structured findings
- Source attribution (which docs were used)
- Citations with provenance
- Confidence indicators

## Install AI-Q server

```bash
# Docker Compose (quickstart)
git clone https://github.com/NVIDIA/AIQ
cd AIQ && docker compose up

# Or Helm (production)
helm install aiq ./charts/aiq
```

Docs: https://github.com/NVIDIA/AIQ
