---
name: colony
description: >-
  Use when user says "Colony", "Colony plan", or "Colony task". Colony workflow: live plans, lanes, handoffs, completion evidence.
---

# Colony

Colony is a **local-first coordination substrate** that makes multi-agent
coding runs safe through shared file claims, compact memory, and durable
handoffs. Agents see ownership and prior decisions before editing files —
parallel work goes from risky to reliable.

> Inline `/CLAUDE.md` already injects a short version of the operating
> contract every session. This skill is the full version: triggers, the
> MCP tool surface, the startup/shutdown loops, and progressive-disclosure
> patterns for memory. When you have this skill loaded you don't need the
> inline copy.

## When to use

Direct triggers:
- "hand this off", "handoff", "pass work to <agent>"
- "claim this file", "claim the file before editing", "who owns <file>"
- "check the inbox", "what needs me", "see active lanes"
- "post a decision", "save this for the next agent", "share ownership"
- "what's blocking me", "what's stalled", "rescue stranded"
- `/colony`, `/task`, `/handoff`, `/claim`, `/inbox`

Indirect — implies Colony first:
- "two agents are editing the same file" → claim before edit
- "I started this, another agent should finish" → handoff or relay
- "what did we decide about X?" → search → get_observations
- "is anyone working on this?" → hivemind_context
- "this task has history we need to remember" → task_post (not OMX notepad)
- "agent stopped mid-task" → rescue_stranded_scan

## When NOT to use

- Single-agent work with no file contention (just edit).
- One-line typos, version bumps, comment fixes (claims add noise).
- Reading to understand — only claim when about to mutate.
- Local scratch notes that won't affect another agent (use OMX `/note`).
- "Just merge this PR" with no concurrent worker (no coordination needed).

If a prompt sounds like Colony but actually has no other agent involved, skip
the contract and do the work directly.

## Startup contract — run before any work

```
1. hivemind_context     → live lanes, file ownership, memory hits, warnings
2. attention_inbox      → pending handoffs, unread messages, blockers, stale lanes
3. task_ready_for_agent → pick claimable work matched to this agent (auto-claims)
   ┌─ accept a pending handoff:  task_accept_handoff
   └─ accept a pending relay:    task_accept_relay
4. (queen-plan flow) task_plan_claim_subtask  ← if working from a published plan
5. task_claim_file <path> ← claim each touched file BEFORE editing it
6. task_note_working { branch, task, blocker, next, evidence }
```

Skip this loop only if you are 100% solo and there is no shared task scope.

## During work

- Update `task_note_working` after meaningful progress. Keep `next` explicit
  so a handoff in 30 seconds would be safe.
- Use `task_post` for decisions / blockers / answers other agents will need.
- Run focused verification (tests, type-check, lint) for the touched behavior
  — not the whole repo.
- If you start touching a file you didn't claim, run `task_claim_file` first.
  `task_drift_check` reports overlap if you forget.

## Shutdown / finish contract

Before stopping (whether complete, blocked, or out of quota):

```
1. git status                      ← identify dirty files
2. If dirty: commit finished work, hand off unfinished work, or revert
                                     intentionally abandoned edits
3. task_note_working {
     branch, task, dirty files, blocker, next step, evidence
   }
4. Release or weaken claims before abandoning work so stale strong
   ownership does not block the next agent
```

## Quota-safe handoff (before session/turn cap)

When you may disappear (rate-limit, quota, turn-cap):

```
task_relay {
  to:     <agent-or-queue>,
  task:   <task-id>,
  files:  [<claimed paths>],
  dirty:  [<git status output>],
  branch: <name>,
  last_verification: <what passed>,
  next:   <one explicit next action>
}
# OR a normal handoff if the receiver is already known
task_hand_off { to, task, files, summary, next }
```

Mark claims `handoff-pending` or release them before exit — no strong claims
should be left without an active handoff or TTL.

If unsure, run the coordination sweep guidance first
(`rescue_stranded_scan` + `task_claim_quota_release_expired`) and follow
its release/handoff recommendation.

## MCP tool surface (grouped by lifecycle)

### Startup & navigation
- `hivemind_context` — live lanes, ownership, memory hits, warnings
- `attention_inbox` — handoffs, unread messages, blockers, stale lanes
- `task_ready_for_agent` — pick + auto-claim work for this agent
- `startup_panel` — compact all-in-one resume card

### Memory & search (use progressive disclosure — IDs first, bodies later)
- `search` — find compact observation IDs by query
- `get_observations(ids)` — fetch full bodies AFTER selecting IDs
- `timeline` — chronological observation IDs for one session
- `list_sessions` → `recall_session` — find and audit prior sessions

### Task threads (per-task coordination)
- `task_list` — browse only; NOT the work picker (use task_ready_for_agent)
- `task_timeline` — compact activity IDs for one task
- `task_post` — decisions, blockers, answers, notes
- `task_note_working` — resumable state (branch, task, blocker, next, evidence)
- `task_claim_file` — claim before editing; visible to other agents
- `task_message` / `task_messages` / `task_message_claim` /
  `task_message_mark_read` / `task_message_retract` — agent-to-agent comms
- `task_drift_check` — edits-vs-claims overlap detection
- `task_link` / `task_unlink` / `task_links` — relate task threads
- `task_updates_since` — incremental fetch since a checkpoint

### Handoffs & relays
- `task_hand_off` — transfer work + optional file claims
- `task_accept_handoff` / `task_decline_handoff`
- `task_relay` — quota-safe handoff (sender may disappear)
- `task_accept_relay` / `task_decline_relay`
- `task_claim_quota_accept` / `task_claim_quota_decline` /
  `task_claim_quota_release_expired` — half-claim management after quota

### Proposals & foraging
- `task_propose` — weak future-work candidate
- `task_reinforce` — promote / reinforce
- `task_foraging_report` — pending + promoted proposals
- `agent_get_profile` / `agent_upsert_profile` — agent capability weights

### Queen plans (multi-agent wave work)
- `queen_plan_goal` — decompose goal into a wave plan
- `task_plan_publish` — publish spec-backed plan + subtasks
- `task_plan_validate` — preflight overlaps / wave errors
- `task_plan_list` — list plans + next available subtasks
- `task_plan_claim_subtask` — claim one subtask + file scope
- `task_plan_complete_subtask` — finish + release claims
- `task_plan_status_for_spec_row` — has this spec row a subtask?
- `task_autopilot_tick` — stateless one-action next decision

### OpenSpec integration
- `spec_read` — parsed SPEC.md + hash
- `spec_change_open` → `spec_change_add_delta` → `spec_archive` — durable change
- `spec_build_context` — task-scoped spec context
- `spec_build_record_failure` — record failures, maybe promote invariants
- `openspec_sync_status` — drift report between tasks and spec artifacts

### Examples & suggestions
- `examples_list` / `examples_query` — search indexed patterns
- `examples_integrate_plan` — deterministic integration guidance
- `task_suggest_approach` — similarity-backed guidance from past tasks

### Rescue & health
- `rescue_stranded_scan` — dry-run identify stalled lanes
- `rescue_stranded_run` — emit rescue relays, release orphan claims
- `savings_report` — live MCP receipts + reference token savings
- `bridge_status` — bridge health & lifecycle state

## Progressive disclosure pattern (memory)

Don't hydrate everything upfront. The cheap calls return IDs only:

```
search("auth refresh flow")     →  [obs_a1, obs_b9, obs_c2]   # compact, ~50 tok
↓ pick the 1-3 that look right
get_observations([obs_b9])      →  full body                  # ~300 tok each
```

Same shape for tasks: `task_timeline(task_id)` → IDs → `get_observations(ids)`
on the few you actually need. Avoid `task_list` as a "what should I work on"
picker — use `task_ready_for_agent` so claims are atomic.

## RTK command policy (token-optimized shells)

When running shell commands inside Colony work, prefix with `rtk` for
token-optimized output: `rtk ls`, `rtk read`, `rtk grep`, `rtk git status`,
`rtk gh pr view`, `rtk pytest`, `rtk tsc`, `rtk lint`. Use `rtk err <cmd>`
or `rtk test <cmd>` for failure-only output. Use `rtk proxy <cmd>` for raw
passthrough. If `rtk` isn't installed in the active env, note that and run
the underlying command compactly.

## Pointers — Colony repo docs

Repo: `/home/deadpool/Documents/recodee/colony/`

| File | Use when |
| --- | --- |
| `docs/mcp.md` | Looking up the exact arg shape of an MCP tool |
| `docs/architecture.md` | Understanding write/read paths, compression, storage |
| `docs/compression.md` | Caveman grammar / token preservation rules |
| `docs/agentic-bridge.md` | OMX PreToolUse hook bridge contract |
| `docs/proposal-task-threads.md` | Proposal lifecycle, reinforcement thresholds |
| `docs/QUEEN.md` | Wave plan decomposition, gating, claimable subtasks |
| `docs/ruflo-sidecar.md` | Ruflo browser/security tool integration boundary |
| `docs/development.md` | Dev workflow, performance budgets |
| `SPEC.md` | Source of truth for invariants & change deltas |
