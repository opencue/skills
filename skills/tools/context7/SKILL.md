---
name: context7
description: Fetch up-to-date, version-specific library/API docs to avoid outdated or hallucinated APIs. Use when the user says "use context7", "latest docs for X", or codes against a fast-moving library.
allowed-tools: Bash(ctx7:*), Bash(npx:*)
category: tools
tags: [tools, documentation, context7, mcp, libraries]
metadata:
  version: 1.0.0
  homepage: https://context7.com
---

# Up-to-date library docs with Context7

Context7 pulls version-specific documentation and real code examples from a
library's source and drops them into context. It kills the two failure modes of
training-data answers: outdated APIs, and hallucinated methods that don't exist.

Two surfaces, same data. Use whichever is wired:

- **MCP** (`context7` server, ships in `core`): call `resolve-library-id`, then
  `query-docs`. No shell needed.
- **CLI** (`ctx7`): same lookups from the terminal.

## Prerequisites

The `context7` MCP ships in cue's `core` profile (no API key needed). For the
standalone CLI:

```bash
npm install -g ctx7    # or run on demand with: npx ctx7 <cmd>
```

For higher rate limits, get a free key at https://context7.com/dashboard and set
`CONTEXT7_API_KEY` in your environment.

## When to reach for it

Pull docs before writing code against any library whose API may have moved since
your training cutoff: frameworks (Next.js, Remix), SDKs (Supabase, Stripe,
OpenAI), infra (Cloudflare Workers, Vercel), CSS (Tailwind). If the user names a
version like "Next.js 15 middleware", Context7 matches that version.

## Step 1: Resolve the library id

A Context7 id looks like `/vercel/next.js` or `/supabase/supabase`. If the user
already gave one, skip to Step 2.

Via MCP: call `resolve-library-id` with the library name plus the question.

Via CLI:

```bash
ctx7 library "next.js" "app router middleware"
```

## Step 2: Fetch the docs

Via MCP: call `query-docs` with the resolved `libraryId` plus the question.

Via CLI:

```bash
ctx7 docs /vercel/next.js "add middleware that checks a JWT cookie"
```

Read the returned snippets, then write the implementation against them, not
against memory.

## Example

User: "Show me the Supabase email/password sign-up API. use context7"

```bash
# Step 1 — resolve (skip if the id is known)
ctx7 library "supabase" "email password sign-up"
# → /supabase/supabase

# Step 2 — fetch version-specific docs
ctx7 docs /supabase/supabase "email and password sign-up"
```

Then write the `supabase.auth.signUp(...)` call straight from the returned
snippet.

## Rules

- **Resolve before querying.** A bare library name needs `resolve-library-id`
  first; `query-docs` takes a Context7 id, not a name.
- **Pass the version when the user gives one.** "Next.js 14" and "Next.js 15"
  return different docs; include it in the query.
- **Prefer the MCP when it is loaded** (it is in `core`); fall back to the
  `ctx7` CLI only when the MCP tools are not available.
- **Quote, do not paraphrase from memory.** The point of Context7 is the fetched
  snippet; write code against what it returns, not what you recall.
- **No key is fine.** It works unauthenticated at lower rate limits; only add
  `CONTEXT7_API_KEY` if you hit limits.

## Next step

Name the library plus task ("Supabase email/password sign-up", "Cloudflare
Worker caching JSON for 5 min") and run Step 1 to resolve its id.
