---
name: strapi-mcp-setup
description: 'Use when connecting an AI client to Strapi over MCP: the built-in content-management MCP server and the Kapa-powered Strapi Docs MCP server. Covers enabling, tokens, wiring.'
tags: [strapi, mcp, ai, content-management, claude-code]
---

# Strapi MCP Setup

Wire an AI client (Claude Code, Cursor, Claude Desktop) to Strapi's two MCP
servers.

## The Two Servers

| Server | Purpose | Auth | Endpoint |
|---|---|---|---|
| **strapi-mcp** | Create/read/update/delete/publish content in *your* Strapi | Admin API token | `<your-strapi>/mcp` |
| **strapi-docs** | Query the Strapi documentation for accurate, current answers | None | `https://strapi-docs.mcp.kapa.ai` |

The `strapi` cue profile wires both already (`mcps: [strapi-docs, strapi-mcp]`).
This skill covers turning them on and authenticating.

## Prerequisites

- For **strapi-mcp**: a running Strapi **v5.47.0+** instance and an Admin API
  token. The content tools available depend on that token's permissions.
- For **strapi-docs**: nothing, it is hosted and unauthenticated.
- Optional manual wiring uses `npx mcp-remote`.

## strapi-mcp (content management)

### 1. Enable the server

Add the `mcp` block to your Strapi server config and restart:

```ts title="config/server.ts"
export default ({ env }) => ({
  host: env('HOST', '0.0.0.0'),
  port: env.int('PORT', 1337),
  app: { keys: env.array('APP_KEYS') },
  mcp: { enabled: true },
});
```

The endpoint becomes available at `/mcp` (e.g. `http://localhost:1337/mcp`).
It uses Streamable HTTP, is stateless, and only accepts POST (GET/DELETE
return 405).

### 2. Create an Admin token

Admin panel → **Settings → API Tokens → Create new token**. Scope it to the
content actions you want the AI to perform. Copy the value once.

### 3. Connect Claude Code

```bash
claude mcp add strapi-mcp --transport http http://localhost:1337/mcp \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

Restart Claude Code, then run `/mcp` to confirm `strapi-mcp` is connected.

### Via the cue profile

The profile's registry entry reads two env vars. Set them (profile `env:` or
your shell) before materializing:

```bash
export STRAPI_URL="http://localhost:1337"
export STRAPI_ADMIN_TOKEN="paste-admin-token-here"
```

The entry expands to an HTTP server at `${STRAPI_URL}/mcp` with the bearer
header. Permission changes (revoking/editing the token) take effect on the
next request, there is no session to restart.

## strapi-docs (documentation)

Zero-config. The cue profile wires it as an HTTP MCP at
`https://strapi-docs.mcp.kapa.ai`. To add it elsewhere manually:

```json title=".cursor/mcp.json or .vscode/mcp.json (servers→type http)"
{ "mcpServers": { "strapi-docs": { "url": "https://strapi-docs.mcp.kapa.ai" } } }
```

Tip: prefix doc questions with `Use the strapi-docs MCP server to answer:` so
the model queries live docs instead of stale training data.

## Rules

- Scope the Admin token to the minimum actions the AI needs; it gates every
  content tool.
- Never commit the Admin token; pass it through env (`STRAPI_ADMIN_TOKEN`).
- strapi-mcp needs the server running and v5.47+; until then it errors, 
  strapi-docs still works standalone.
- The content MCP is Beta; verify destructive actions (delete/unpublish)
  before letting an agent run them unattended.

## Next Step

Once connected, use `building-with-strapi` for the data model the MCP tools
operate on, or `strapi-content-api` to consume the same content over HTTP.
