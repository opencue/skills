---
name: operate
description: >-
  Use when the user wants to run, drive, or supervise the x-growth-bot (the
  X / Twitter growth bot in ~/Documents/x-growth-bot) from inside Claude Code.
  Triggers: "start the bot", "stop the bot", "bot status", "is the loop
  running", "pause the bot", "resume the bot", "draft a reply", "send a DM",
  "run a dry cycle", "show pending replies", "what's the bot doing", "check
  caps", "engage candidates", "growth report". Routes every action to the
  right surface: the `xbot` MCP tools, the `./botctl` wrapper, or
  `python -m xbot.cli`, and enforces the loop-vs-MCP write-safety rule.
triggers:
  - start the bot
  - stop the bot
  - bot status
  - pause the bot
  - resume the bot
  - draft a reply
  - send a DM
  - run a dry cycle
  - show pending replies
  - growth report
allowed-tools: Bash(./botctl:*), Bash(.venv/bin/python:*), Bash(claude:*), Bash(cat:*), Bash(ls:*), Bash(tail:*), Read
requires_mcps:
  - xbot
tags: [xbot, twitter, x, growth, social, bot, operate, mcp]
domain: social
category: operate
---

## What this skill does

Operates the **x-growth-bot** (an autonomous X / Twitter growth bot at
`~/Documents/x-growth-bot`) from a Claude Code session. It picks the correct
control surface for each request and keeps live actions safe when the
background loop is running.

The bot has three control surfaces, all already built:

| Surface | How | Best for |
| --- | --- | --- |
| `xbot` **MCP** | MCP tools (`xbot_status`, `xbot_reply`, …) | reads, control, drafting and posting from inside this chat |
| `./botctl` | Bash wrapper | starting/stopping the loop, operator board, quick status |
| `xbot.cli` | `.venv/bin/python -m xbot.cli <cmd>` | full surface (`preflight`, `propose`, `commit`, `loop`) |

The MCP and the loop are **separate processes sharing the same on-disk state
with no lock**. The one hard rule below exists because of that.

## Prerequisites

The bot lives at `~/Documents/x-growth-bot` and ships its own tooling. No global
install is needed beyond what the repo already provides:

- `./botctl` and `.venv/bin/python -m xbot.cli` come from the repo (the venv is
  created on setup). Run them from the repo root so state files resolve.
- The `xbot` MCP server is registered with `claude mcp add xbot --scope local --
  bash ~/Documents/x-growth-bot/run-mcp.sh`. Newly added tools appear after a
  Claude Code restart.

## When to activate

- "start / stop / restart the bot", "is the loop alive", "bot status"
- "pause the bot" / "resume the bot" (emergency circuit)
- "draft a reply to this tweet", "send a DM", "show pending replies"
- "run a dry cycle so I can watch it think"
- "show today's caps / growth / attribution / report"
- "what did the bot skip and why" (audit log)

## The one hard rule (loop vs MCP writes)

The live `loop` daemon and the `xbot` MCP each build their own session on the
same account and share caps / history / circuit files with **no cross-process
lock**. Reads and control via MCP are always safe. For **live writes** via MCP
(`xbot_reply`, `xbot_dm`, `xbot_like`, `xbot_retweet`, `xbot_follow`,
`xbot_cycle` with `dry_run=False`):

1. Check the loop first: `./botctl status`
2. If it is alive, pause or stop it before the live write:
   `./botctl pause "manual MCP session"` (or `./botctl stop`)
3. Do the live write.
4. Resume: `./botctl resume` (or `./botctl start`).

Skipping this risks double-counted caps or two processes posting at once, which
is exactly the ban-risk the circuit guards against.

## Step 1: Orient before acting

Always read state before any write. From inside this chat, prefer the MCP:

- `xbot_status`: account health, remaining caps, pacing window (read-only)
- `xbot_control`: circuit state + per-action caps + pending + growth in one call
- `xbot_plan`: one-shot operator context (status + persona + candidates)

From a shell:

```bash
cd ~/Documents/x-growth-bot
./botctl status      # is the loop alive? pid + next-cycle heartbeat
./botctl board       # one-shot operator board
```

If the MCP tools are not visible in this session, see "Tools missing?" below.

## Step 2: Pick the surface for the request

**Reads / dashboards (always safe, no loop interaction):**

| Want | MCP tool | CLI fallback |
| --- | --- | --- |
| Account health + caps | `xbot_status` | `xbot.cli status` |
| Operator board | `xbot_control` | `xbot.cli control` |
| Growth dashboard | `xbot_report` | `xbot.cli report` |
| Follower delta | `xbot_followers` | `xbot.cli followers` |
| Follow-back attribution | `xbot_attribution` | `xbot.cli attribution` |
| Engage candidates | `xbot_candidates` | `xbot.cli discover` |
| Brain judgement of candidates | `xbot_think` | `xbot.cli think` |
| Why it skipped | `xbot_log` | `xbot.cli log` |
| Parked replies | `xbot_pending` | `xbot.cli pending` |
| Inbound DMs | `xbot_inbox` | n/a |

**Control (safe, no posting):**

- Pause: `xbot_pause("reason", hours=6)` or `./botctl pause "reason"`
- Resume: `xbot_resume()` or `./botctl resume`
- Read/set a knob: `xbot_config("actions.reply.daily_cap")` (omit value to read)

**Loop lifecycle (shell only):**

```bash
./botctl start          # LIVE engagement loop, detached, pid-managed
./botctl start --dry    # DRY-RUN loop (no live actions) to watch it think
./botctl stop
./botctl restart
```

**Live writes (apply the hard rule above first):**

- Post a reply: `xbot_reply(...)`: runs every guard (trust gate, caps, circuit)
- Send a DM: `xbot_dm(...)`: answer inbound by passing the inbound id
- Like / retweet / follow: `xbot_like`, `xbot_retweet`, `xbot_follow`
  (each defaults to `dry_run=True`; pass `dry_run=False` to act)
- One full cycle: `xbot_cycle(dry_run=True)` first, then `dry_run=False`

## Step 3: Draft, gate, then post

Never post raw. The bot has a trust gate; use it.

1. Draft the reply text yourself (read `xbot_persona` for the voice + rules).
2. Second-opinion it: `xbot_trust_check(tweet_text, draft)` runs the
   adversarial skeptic panel.
3. Only on a pass, call `xbot_reply(...)` (after the loop-safety rule).

For DMs, `xbot_dm_plan` gives the one-shot context (caps + circuit + inbox)
before you draft.

## Step 4: Verify the action landed

After a write, confirm with a read:

- `xbot_status`: caps decremented as expected
- `xbot_log`: the action appears in the audit log
- `./botctl status`: loop heartbeat unchanged if you paused/resumed cleanly

## First live run

Before the first `--live` run, run the offline go/no-go check:

```bash
cd ~/Documents/x-growth-bot
.venv/bin/python -m xbot.cli preflight
```

## Tools missing?

Newly-added MCP tools need a **Claude Code session restart** to appear.
`claude mcp get xbot` showing `✓ Connected` only means the server handshakes,
not that this session has the tools. If `xbot_*` tools are not callable, fall
back to `./botctl` / `xbot.cli` in Bash for this session and restart for the
MCP next time.

## What this skill does NOT do

- Does not write tweet/reply/DM copy for you. You draft; the bot gates and posts.
- Does not edit the bot's source (`src/xbot/`). Use a coding profile for that.
- Does not bypass caps, the circuit, or the trust gate. If an action is blocked,
  surface the reason; do not work around the guard.
- Does not manage X login / cookies. Auth recovery is a separate concern.

## Examples

<example>
User: is the bot running and how are we doing today?
Action: Call `xbot_control` (or `./botctl board`) for circuit + caps + growth in
one shot, then `xbot_status` if more cap detail is needed. Report loop liveness,
remaining caps, and follower delta. No writes.
</example>

<example>
User: pause the bot, I think it's being too aggressive
Action: `xbot_pause("operator: too aggressive", hours=6)` (or
`./botctl pause "too aggressive"`). Confirm with `xbot_control` that the circuit
is open. Tell the user how to resume.
</example>

<example>
User: draft a reply to this tweet and post it
Action: Read `xbot_persona`. Draft the reply. Run `xbot_trust_check(tweet, draft)`.
If it passes: run `./botctl status`; if the loop is live, `./botctl pause` first,
then `xbot_reply(...)`, then `./botctl resume`. Verify with `xbot_log`.
</example>

<example>
User: run a dry cycle so I can see what it would do
Action: `xbot_cycle(dry_run=True)` (no loop interaction needed for a dry run).
Summarize the candidates it judged and the actions it would have taken.
</example>

<example>
User: show me the replies waiting for my approval
Action: `xbot_pending` (or `xbot.cli pending`). List each parked reply with its
target so the user can approve. Read-only.
</example>
