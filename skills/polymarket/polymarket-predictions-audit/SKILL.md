---
name: polymarket-predictions-audit
description: >-
  Use when user says "audit my predictions", "how is the model doing", "show prediction accuracy", "why is the model wrong", or "review my Brier score". Reads the local predictions.jsonl + Brier report via `polymarket-live` MCP and explains where the model agrees/disagrees with reality. NOT for opening or resolving predictions.
---

# Polymarket predictions audit

Use this skill when the user wants to know how well their paper-trading
predictions are tracking — accuracy, Brier vs the Polymarket baseline,
calibration, direction bias, and which recent predictions were the worst
misses.

## When to use it

- "audit my predictions"
- "how is the momentum model doing?"
- "why is the watch panel always saying UP?"
- "show me where the model is wrong"
- "is the model beating Polymarket?"

## When NOT to use it

- The user wants to **open or resolve** predictions → run the CLI by
  hand. The MCP is read-only.
- The user wants a live BTC market snapshot → use the
  `polymarket-research` skill instead.

## Recipe

1. **Health-check the store.** Call
   `mcp__polymarket-live__predictions_list(status="all", limit=1)` first
   and read `total_in_store` from the result. If 0, tell the user the
   JSONL store is empty and to run `polymarket predict watch --auto` or
   `polymarket predict open` to start populating it; stop here.

2. **Get the summary numbers.** Call
   `mcp__polymarket-live__predictions_stats()` for the all-time roll-up
   (accuracy, avg confidence, Brier, direction counts, market-baseline
   accuracy). If the user asked about a recent window, pass
   `last_n=<N>`.

3. **Get the calibration / Brier-vs-baseline view.** Call
   `mcp__polymarket-live__predictions_backtest(model="polymarket")` for
   the Brier score with bootstrap CI, log-loss, and
   `model_vs_polymarket_brier_delta`. Negative delta = model beats the
   crowd; positive = model is worse than just trusting Polymarket.

4. **Find the worst misses.** Call
   `mcp__polymarket-live__predictions_list(status="resolved", limit=50, newest_first=True)`,
   then locally rank by `|confidence × (1 − resolution.correct)|` (i.e.
   "high-confidence wrongs"). Show the top 3–5 with: time, direction,
   confidence, p_open, p_close, slug.

5. **Optional: cross-check with current model thinking.** Call
   `mcp__polymarket-live__predict_think(models=["polymarket","momentum","blend"])`
   so the user sees what each model would say *right now* — useful to
   tell apart "model has changed since the bad call" from "model
   systematically wrong".

## Reporting style

- Lead with the headline number: e.g. "Accuracy 54% over 87 resolved
  predictions (Brier 0.241, beating the Polymarket-implied baseline by
  Δ−0.012)."
- Then breakdown: UP-call accuracy vs DOWN-call accuracy. A skew
  (e.g. 70% UP-calls / 30% DOWN-calls) is the smoking gun for "why is
  it always UP" complaints — when the model name is `polymarket` and
  the market is trading at 0.505 the loop will always pick UP. Surface
  that and suggest `--auto-model momentum` or `--auto-model blend`.
- For the misses, format as a tiny markdown table; do NOT dump raw JSON.
- If `model_vs_polymarket_brier_delta > 0`, gently note that the user is
  losing edge vs just trusting the order book.

## Failure modes

- Backtest takes >10s → split the window with `from_iso` / `to_iso` and
  call it twice; or skip backtest and only show stats.
- Calibration array is empty → fewer than ~10 resolved predictions; tell
  the user to come back when the loop has been running longer.
- MCP not registered → tell user to add `polymarket-live` under
  `mcpServers` in `~/.claude.json` and restart Claude.
