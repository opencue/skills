---
name: colony-prompts
description: >-
  Use when user says "Colony prompts" or "Colony handoff". Prompt boundaries, task readiness, handoff wording for Colony.
---

# Colony Planner Prompts

Reusable workflow for turning "let's port feature X into colony" into a set
of parallel-safe agent prompts that drop straight into the colony-hivemind
planner UI. Each prompt is a self-contained instruction sheet for one agent
running in its own `agent/*` worktree.

## When to use

Direct triggers:
- "colony:prompts", "/colony-prompts"
- "generate N agent prompts for ..."
- "add to the recodee/colony planner"
- "split this into parallel agent prompts"
- "wave plan for colony"
- "scaffold prompts for the colony planner"

Indirect — implies this skill:
- User just got a feature-integration recommendation (e.g. "best of mempalace
  → colony") and says "do a plan with N agents that can run in parallel"
- "Can you add prompts so the planner can dispatch this work?"

## When NOT to use

- Single-agent work, single-file fix, typo, version bump.
- The user wants an OpenSpec change but no agent dispatch.
- The user wants a doc, not executable agent prompts.
- The work fits one `T0` lane — adding 15 prompts for a one-line fix is noise.

## Canonical paths

- Planner prompts directory:
  `/home/deadpool/Documents/recodee/apps/frontend/public/colony-planner/prompts/`
- File name shape: `agent-NN.md` (zero-padded only when ≤ 99; flat decimal
  after that — match what's already there).
- Status marker (read by the planner UI):
  `<!-- colony-planner-status: todo -->` flips to `done` only when the agent
  has merged proof.

The planner page reads these markers and groups prompts into waves based on
the order they're filed. The planner itself is at
`/home/deadpool/Documents/recodee/apps/frontend/app/(app)/colony-hivemind/planner/`.

## Required prompt format

Every prompt is a single markdown file with exactly this shape:

```markdown
<!-- colony-planner-status: todo -->

You are working in /home/deadpool/Documents/recodee/colony.

Goal: <one-sentence outcome>.

Read:
- <source files this agent must understand before editing>
- <existing-feature siblings for shape>
- <the upstream OpenSpec change/context if any>

Implement:
- <concrete file path 1 + what to add/change>
- <concrete file path 2 + ...>
- <explicit DO-NOT lines for files claimed by sibling agents>

Constraints:
- File ownership: <exact paths this agent owns this wave>.
- <invariants — perf budget, backward-compat, no-network, etc.>
- <CLAUDE.md rule citations where relevant>

Proof:
- <pnpm filter test command>
- <typecheck/build command>
- <git diff <owned-paths>>
```

Do not invent extra sections. The planner UI parses this shape literally.

## Numbering

1. Read the directory once: list `agent-*.md` and find the highest number.
2. Continue from `next = highest + 1`.
3. Numbers are global across all themes — never reuse, never renumber.
4. The just-finished mempalace track lives at 230–244. Pick after the
   current highest (verify before writing — other sessions may have added
   prompts since).

## Parallel-safety model

The planner can dispatch every prompt in a wave concurrently, so within a
wave, no two prompts may write the same file. Across waves, dependencies
are allowed.

Concrete rules every prompt must respect:

- **Each agent claims a disjoint file set.** State the claim explicitly in
  the `Constraints` section under "File ownership".
- **No two agents in the same wave touch the same file.** If a registration
  file (e.g. `apps/mcp-server/src/server.ts`, `packages/hooks/src/index.ts`)
  has to be edited by multiple features, schedule those edits in serial
  waves with one owner per wave.
- **New files > shared files.** Prefer `packages/<pkg>/src/handlers/foo.ts`
  (new) over editing `packages/<pkg>/src/index.ts` (shared) in the same
  wave.
- **Pure modules first, wiring last.** Pure logic (scorers, validators,
  reducers) goes in early waves. Pipeline/registration wiring goes in the
  last impl wave before the conformance gate.

## Wave layout heuristic

For an N-agent feature port (typical N = 10–20), default to 5 waves:

| Wave | Purpose | Sample agents |
|---|---|---|
| W1 | Capability context, umbrella OpenSpec change, package skeletons | 3–4 |
| W2 | Per-feature isolated implementations (pure modules, new files) | 3–5 |
| W3 | Schema migrations, MCP tool registration, config schema, hook exports | 3–5 |
| W4 | Wiring (search pipelines, MCP handler args, sanitizer hooks) | 2–3 |
| W5 | Conformance gate (single sequential agent) | 1 |

The gate prompt is always last and always sequential. Model it on
`scripts/check-symphony-conformance.ts` — the colony repo already has the
pattern.

## Required content per prompt

- **Goal** — one verifiable outcome. Not "improve search" but "wire
  applyTimeDecay into search/index.ts gated by `search.timeDecay.enabled`".
- **Read** — the actual file paths the agent must read first. Include the
  upstream source file under `examples/<thing>/` when porting.
- **Implement** — concrete file paths. Every line is an action. Include
  explicit `DO NOT touch <file>` lines for any shared file claimed by a
  sibling agent in the same wave.
- **Constraints** — `File ownership:` line listing exact paths, then the
  invariants (perf budgets, backward-compat, local-first, no network calls,
  CLAUDE.md rule numbers).
- **Proof** — exact commands. At minimum: one `pnpm --filter <pkg> test ...`
  matching the agent's owned tests; one typecheck or build; one
  `git diff <owned-paths>`.

## Hard guardrails (apply to every prompt)

These come straight from `colony/CLAUDE.md` and `recodee/CLAUDE.md`:

1. **Worktree discipline.** Every agent works inside an `agent/*` worktree
   started via `gx branch start "<task>" "claude-code"` (or `bash
   scripts/agent-branch-start.sh ...`). Never edit on `main`.
2. **Read-before-edit.** The prompt's `Read` block must list every file the
   agent will edit; Claude Code rejects `Edit` on unread files.
3. **Compression-first.** No prompt may add a write path that bypasses
   `@colony/compress` (rule #2). All persisted prose goes through the
   `MemoryStore` facade. Reject ports that demand verbatim storage.
4. **No technical-token compression.** Code blocks, URLs, file paths, shell
   commands, version numbers, dates, numeric literals stay byte-for-byte
   (rule #3). Reranker/sanitizer prompts that quote user content must
   preserve these.
5. **Hot-path budget.** Hook handlers stay under 150 ms p95 (rule #6). The
   prompt must state the budget when the agent touches `packages/hooks/`.
6. **No default network calls.** Local-first by default; remote providers
   are BYOK opt-in (rule #8). State this explicitly when adding embedder or
   reranker code.
7. **Migrations are forward-only.** New SQL files are numbered, idempotent,
   and never destructive on re-run (rule #5 in storage README).
8. **Locked files.** `rust/codex-lb-runtime/src/main.rs` is integrator-only
   per recodee/CLAUDE.md. `frontend/src/utils/account-working.ts` is
   regression-locked. Reject prompts that touch them without explicit
   integrator override.
9. **Progressive disclosure in MCP.** New MCP tools return compact
   list shapes; full bodies via a follow-up fetch (rule #5 in colony's
   CLAUDE.md). State this when registering tools.
10. **Conformance gate is non-bypassable.** The final prompt runs a script
    that walks tasks.md checkboxes and exits 1 if any required item lacks
    a `task_proof_record`. No manual checkmarks.

## Workflow

When the user invokes this skill:

1. **Locate the planner.** Confirm
   `/home/deadpool/Documents/recodee/apps/frontend/public/colony-planner/prompts/`
   exists. List existing prompts to find the next number.
2. **Read the source.** If the user references `examples/<thing>/`, read
   the README, CLAUDE.md, MISSION.md, ROADMAP.md (whichever exist) before
   proposing a breakdown. Do not skim — the breakdown depends on
   understanding what's actually portable.
3. **Propose a breakdown** in the chat first: list the candidate features,
   the ones to reject, and the ones to adopt. Group adopted features into
   waves with file-ownership invariants. Surface conflicts before writing
   files.
4. **Get a quick confirm or proceed** — if the user already said "without
   stopping" or "just do it", continue.
5. **Write all N prompts** in parallel `Write` tool calls (they're
   path-disjoint). Each file goes to
   `apps/frontend/public/colony-planner/prompts/agent-NN.md`.
6. **Verify** with one `ls` confirming all files landed and sizes are
   reasonable (1–3 KB each — much larger means the prompt is bloated).
7. **Reply with a wave map table** and the file-ownership invariants list.
   Do not paste the prompts back — they're durable on disk.

## Working state

If interrupted, post a Colony note:

```
task_post kind=note
content="branch=<branch>; task=colony-prompts-<theme>;
blocker=<blocker>; next=write agents NN-MM;
evidence=apps/frontend/public/colony-planner/prompts/agent-NN.md"
```

Hand off the unfinished number range to the next agent rather than
overlapping numbers.

## Reference example

The mempalace integration set (agents 230–244, written 2026-05-09) is the
canonical reference for this skill. 15 agents, 5 waves, file-ownership
invariants in every prompt, conformance gate at 244. Read any of those
prompts to see the exact tone and density expected.
