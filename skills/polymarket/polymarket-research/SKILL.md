---
name: polymarket-research
description: >-
  Use when user says "what's the Polymarket market doing", "research a Polymarket market", "BTC 5m snapshot", "look up a Polymarket market", or "what are the odds on X". Live overview via `polymarket-live` MCP — bundles BTC 5m snapshot, market search, and order book. NOT for placing orders.
---

# Polymarket research

Use this skill any time the user asks what a Polymarket market is doing
right now, what the crowd thinks, or to look up a specific market. It
leans entirely on the `polymarket-live` MCP — no shelling out, no
guessing from training data.

## When to use it

- "what's the BTC 5m doing right now?"
- "research the X Polymarket market"
- "what's the price on the 2028 election Yes token?"
- "show me the order book for <market>"
- "is there even a Polymarket market for Y?"

## When NOT to use it

- The user wants to **place an order** → that's the `polymarket bot` lane;
  refer them to the CLI, do not attempt via MCP.
- The user wants to **open a prediction** → `polymarket predict open …`;
  same reason. The MCP is read-only on purpose.

## Recipe

### A. "What's the BTC 5m doing right now?"

1. Call `mcp__polymarket-live__btc_5m_snapshot()` first. It returns
   question, slug, condition_id, seconds_remaining, price_to_beat (BTC
   at window start), current_price (live spot), edge_dollars, edge_pct,
   if_close_now ("UP"|"DOWN"|"TIE"), poly_up_price, poly_down_price,
   poly_implied_up.
2. Report in 3 lines:
   - market name + time-to-close
   - "BTC moved from $X to $Y → if window closed now: <UP|DOWN|TIE>"
   - "Crowd: P(up) = Z (up ¢, down ¢)"
3. Optionally call `mcp__polymarket-live__predict_think(models=["polymarket","momentum","blend"])`
   to overlay model opinions.

### B. "Look up a market"

1. Use `mcp__polymarket-live__markets_search(query, limit=5)` first.
   List the top 3 — for each row include slug + question + last price +
   24h volume + end_date.
2. If the user points at a specific row, call
   `mcp__polymarket-live__markets_get(id_or_slug)` for full detail
   (outcomes, token IDs).
3. If they want depth, call `mcp__polymarket-live__clob_book(token_id)`
   on a relevant outcome and summarise top 5 bids / asks.

### C. "Are the odds moving?"

1. `clob_midpoints([yes_token, no_token])` for a quick snapshot.
2. If they want a time series, point them at `polymarket predict watch`
   for live charts — this skill does not poll a series itself (would
   blow up tokens).

## Reporting style

- Lead with the answer. The user wants the number, not the recipe.
- Always include `slug` (or `id`) when naming a market, so they can
  re-look-up later.
- Quote prices to 3 decimals (`0.485`), volumes to 0 or 1 decimal
  ($24.3M not $24,322,109).
- If `market_status()` reports anything non-OK, surface that first —
  every other tool is going to be junk.

## Failure modes

- MCP not registered → tell the user to add `polymarket-live` under
  `mcpServers` in `~/.claude.json` and restart Claude.
- `RuntimeError: polymarket binary not found` → user needs to build:
  `(cd ~/Documents/polymarket-cli && cargo build --release)`.
- Tool times out → fall back to a `polymarket … -o json …` shell call
  in a Bash tool with the same args; the CLI surface matches one-to-one.
