---
name: acpx
description: Delegate work to another coding agent (codex, claude, gemini, etc.) over the Agent Client Protocol via acpx. Use when the user says "delegate to <agent>", "spawn a sub-agent", or mentions ACP.
category: meta
---

# acpx, talk to other coding agents over ACP

`acpx` is a headless CLI that lets one agent drive another over the **Agent
Client Protocol (ACP)**. Persistent sessions, prompt queueing, structured
tool-call output, soft-close lifecycle. You get a real conversation with the
target agent instead of scraping its terminal.

⚠️ acpx is in alpha; the surface may shift. Pin via `npm install -g acpx@latest`
or `npx acpx@latest` for one-offs. State lives in `~/.acpx/`.

## When to reach for it

- User asks you to **delegate** a task to another agent ("get codex to fix X",
  "have claude refactor Y").
- You're in one harness and the task is clearly a better fit for another
  (e.g. you're in Claude Code and the user wants the Codex CLI to run the
  task because of model availability or workflow preference).
- The user wants **parallel work in the same repo** by different agents
  without stomping on each other.
- You'd otherwise be tempted to `tmux send-keys`, `expect`, or screen-scrape
  another agent's TUI, stop, use acpx instead.

Do **not** use acpx for the agent you're already running inside. Use your
native tools.

## Setup (one-time)

```
npm install -g acpx@latest        # global (faster)
# or
npx acpx@latest <agent> "<prompt>"  # no install
```

Underlying coding-agent CLIs (`codex`, `claude`, `gemini`, etc.) must already
be installed and authenticated separately, acpx is a client, not a bundler.
Run `cue cli install acpx` to install via the cli recipe registry.

## Core commands

```
acpx codex sessions new                   # create a session for this dir
acpx codex 'fix the failing tests'        # run a prompt
acpx codex -s api 'paginate the endpoint' # parallel named session
acpx codex sessions list                  # see what's open
acpx codex status                         # is it running / idle / dead
acpx codex cancel                         # cooperative cancel (sends ACP cancel)
acpx codex sessions close                 # soft-close (keeps history)
acpx codex exec 'one-shot summary'        # stateless, no saved session
```

Substitute `codex` with `claude`, `pi`, `openclaw`, `gemini`, `cursor`,
`copilot`, `droid`, `iflow`, `kilocode`, `kimi`, `kiro`, `opencode`, `qoder`,
`qwen`, `trae`. For custom ACP servers: `acpx --agent './bin/my-acp' '...'`.

## Useful flags

- `--no-wait`, queue prompt, return immediately (fire-and-forget).
- `--format json`, NDJSON event stream, good for automation/jq pipelines.
- `--format quiet`, final assistant text only.
- `--approve-all` / `--approve-reads` / `--deny-all`, permission gates.
- `--cwd <path>`, run against a different working directory.
- `--timeout <s>`, wall-clock cap on a single prompt.
- `--ttl <s>`, keep queue owner alive between prompts (default 300).
- `--file <path>` / stdin, load prompt body from file or pipe.

## Full reference

- Skill source: <https://raw.githubusercontent.com/openclaw/acpx/main/skills/acpx/SKILL.md>
- CLI reference: <https://raw.githubusercontent.com/openclaw/acpx/main/docs/CLI.md>
- Built-in agent list: <https://github.com/openclaw/acpx/blob/main/agents/README.md>

When something's not obvious, read those, they're the canonical source and
they evolve faster than this stub.
