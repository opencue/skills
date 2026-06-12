---
name: ccusage
description: Analyze coding-agent CLI token usage and cost from local logs — Claude Code, Codex, Gemini, Copilot, OpenCode, Amp, Droid and more — as daily, weekly, monthly, or session reports. Use when the user says "ccusage", "how much have I spent", "my token usage", "usage report", "cost breakdown", "how many tokens", or "which model do I use most", or wants to audit AI coding spend. Reads existing logs; no setup.
allowed-tools: Bash(bunx:*), Bash(npx:*), Bash(ccusage:*)
category: tools
tags: [tools, usage, cost, tokens, observability, claude-code, codex]
metadata:
  version: 1.0.0
  homepage: https://ccusage.com
---

# Coding-agent usage & cost with ccusage

`ccusage` reads the local logs your coding-agent CLIs already write and turns them
into token-usage and cost reports. It covers Claude Code, Codex, Gemini CLI, GitHub
Copilot CLI, OpenCode, Amp, Droid, Codebuff, Goose, OpenClaw, Kilo, Kimi, Qwen,
Hermes, and pi-agent. Nothing to instrument: it parses logs already on disk and
prices them from a cached LiteLLM snapshot.

## When to activate

- The user asks how much they have spent on Claude Code, Codex, Gemini, or Copilot.
- The user wants a token-usage or cost report by day, week, month, or session.
- The user asks which model they use most, or for a per-model cost breakdown.
- The user says "ccusage", "usage report", "cost breakdown", or "audit my AI spend".
- The user wants to track usage inside Claude's 5-hour billing windows.

## Examples

Realistic requests and the command each maps to:

- "How much have I spent on Claude Code this month?" → `bunx ccusage claude monthly`
- "Show my token usage by day across every agent." → `bunx ccusage daily`
- "Which model am I burning the most on?" → `bunx ccusage daily --breakdown`
- "What did Codex cost me last week?" → `bunx ccusage codex weekly`
- "Give me a usage report I can paste into Slack." → `bunx ccusage --compact`
- "Total my spend between two dates as JSON." → `bunx ccusage daily --since 2026-05-01 --until 2026-05-31 --json | jq '[.daily[].totalCost] | add'`

## Prerequisites

No install needed. Run it on demand with `bunx` (preferred) or `npx`:

```bash
bunx ccusage --version
```

`bunx` caches the binary after the first run, so repeat calls are fast. If `bun`
is missing, `npx ccusage@latest` works the same way. To pin a global copy:
`npm install -g ccusage`, then call `ccusage` directly.

## Core pattern

Show every detected agent's usage by day, then drill in:

```bash
bunx ccusage              # all detected sources, by day (default)
bunx ccusage session      # group by conversation session
bunx ccusage --json       # same data as structured JSON
```

Expected output is a colored table with date or session rows and columns for input,
output, cache-create, and cache-read tokens plus cost in USD. `--json` emits the
same numbers for scripting.

## Reports

```bash
bunx ccusage daily        # aggregated by date (default)
bunx ccusage weekly       # aggregated by week
bunx ccusage monthly      # aggregated by month
bunx ccusage session      # grouped by conversation session
bunx ccusage blocks       # Claude Code 5-hour billing windows, with active-block monitoring
```

## One agent at a time

Prefix the report with a source name to focus on a single CLI:

```bash
bunx ccusage claude daily      # Claude Code only
bunx ccusage codex daily       # Codex
bunx ccusage gemini daily      # Gemini CLI
bunx ccusage copilot daily     # GitHub Copilot CLI
bunx ccusage opencode weekly   # OpenCode
bunx ccusage amp session       # Amp
bunx ccusage droid daily       # Droid
```

Other sources: `codebuff`, `goose`, `openclaw`, `kilo`, `kimi`, `qwen`, `hermes`,
`pi`. Use `bunx ccusage daily --all` for the explicit unified report.

## Filters and options

```bash
bunx ccusage daily --since 2026-04-25 --until 2026-05-16   # date range
bunx ccusage daily --breakdown                              # per-model cost breakdown
bunx ccusage claude daily --instances                       # group Claude Code by project
bunx ccusage claude daily --project myproject               # filter to one project
bunx ccusage daily --no-cost                                # hide cost columns
bunx ccusage daily --timezone UTC                           # timezone for date grouping
bunx ccusage daily --offline                                # use cached pricing, no network
bunx ccusage --compact                                      # narrow table for screenshots
```

## Programmatic use

Pipe `--json` into `jq` to answer questions in scripts. Top-level keys are the
report name (`daily`, `weekly`, `monthly`, `sessions`, `blocks`) plus `totals`;
each row carries `inputTokens`, `outputTokens`, `totalCost`, and `modelBreakdowns`:

```bash
# Sum cost across every daily row in the report
bunx ccusage daily --json | jq '[.daily[].totalCost] | add'

# Per-model breakdown for Claude Code
bunx ccusage claude daily --json --breakdown | jq '.daily[].modelBreakdowns'
```

Confirm field names with `bunx ccusage daily --json | jq 'keys'` before relying on
them; the schema can shift between major versions.

## What this skill does NOT do

- It does not bill, charge, or change any account. It only reads local logs.
- It does not replace `/cost-report`, which queries a separate cost-tracker SQLite
  database. ccusage needs no tracker and reads raw transcripts instead.
- It does not upload your logs. Pricing is fetched (or cached with `--offline`);
  usage data stays on the machine.
- It cannot report an agent whose logs are absent on this machine.

## Rules

- Prefer `bunx ccusage` over a global install so reports run the latest binary;
  fall back to `npx ccusage@latest` when `bun` is missing.
- Use `--offline` on flaky or air-gapped networks. It prices from the cached
  LiteLLM snapshot instead of fetching, so the command still completes.
- Reach for `--json` whenever the answer feeds a calculation or another tool, and
  parse with `jq` rather than eyeballing the table.
- Pass an explicit source (`ccusage claude ...`) when the user asks about one
  agent, and `--all` when they want every agent in one report.
- Add `--since`/`--until` for "this week" or "last month" questions instead of
  summing rows by hand.
