---
name: api-tester
description: >-
  Use when user says "test API", "API endpoint", or "curl this endpoint". Request setup, auth, assertions, response checks.
---

# api-tester

Local CLI that batch-validates LLM API keys against each provider's `/v1/models`
endpoint (or a chat completion when `--model` is given). Auto-detects provider
by key prefix, retries on transient errors, masks output by default.

> Source: <https://github.com/recodeee/api-tester> (private, recodee org)
> Local clone: `~/Documents/api-tester/`

## When to load this skill

- User says: test api keys, validate keys, check which keys work, audit keys,
  rotate keys, find live keys, are these keys valid, sk- key checker.
- User pastes ≥1 line(s) starting with `sk-`, `sk-ant-`, `xai-`, `AIza`, or
  `sk-or-` and asks for status.
- User mentions credential leak / git-secret cleanup and wants to know which
  exposed keys are live → call api-tester first, then push them through
  rotation.

## When NOT to load

- Only goal is to make a single real API call → use the provider SDK directly.
- User wants to test their **own** key once, in shell → `curl` with the
  Authorization header is fine and documented in each provider's docs.
- Code-quality review of a key-handling module → use `code-review`.
- Looking for hardcoded secrets in a repo → use `security-review` first; only
  bring in `api-tester` to triage which detected secrets are still active.

## Hard rules

- **Never** add the user's keys to chat output, commit messages, PR titles, or
  any file that might be pushed. Pass them through stdin or a gitignored
  `keys.txt`.
- **Never** commit `keys.txt`, `keys-*.txt`, `*.keys`, or `.env*` from inside
  the api-tester repo (`.gitignore` blocks them — don't override).
- A `valid` line for a key the user does not recognize ⇒ **rotate immediately**
  via the provider's console (links in the repo README).
- Default to masked output. Only pass `--show-full` if the user explicitly
  asks AND the destination is the user's terminal (not a log/PR/note).

## Install (one-time)

```bash
# pipx is the cleanest — isolated venv, on PATH automatically
pipx install ~/Documents/api-tester
api-tester --help
```

If `pipx` isn't installed: `pip install --user ~/Documents/api-tester` (needs
`~/.local/bin` on `$PATH`), or symlink the shell shim:

```bash
ln -s ~/Documents/api-tester/bin/api-tester ~/.local/bin/api-tester
```

Or skip install entirely:

```bash
python3 ~/Documents/api-tester/api_tester.py keys.txt
```

## Provider routing (auto-detect)

| Prefix          | Provider      | Auth header                         |
| --------------- | ------------- | ----------------------------------- |
| `sk-ant-`       | anthropic     | `x-api-key`, `anthropic-version`    |
| `sk-or-`        | openrouter    | `Authorization: Bearer`             |
| `xai-`          | xai           | `Authorization: Bearer`             |
| `AIza`          | gemini        | `x-goog-api-key`                    |
| `sk-` (other)   | openai *      | `Authorization: Bearer`             |

`*` ambiguous — `sk-` could be openai/deepseek/siliconcloud. Default is openai;
override with `--default-sk` or per-line `provider:key`:

```text
deepseek:sk-...
siliconcloud:sk-...
openai:sk-...
```

## Cheatsheet

Three input modes:

- **inline** — `api-tester sk-... [more keys ...]`
- **file** — `api-tester <path>` (any absolute or relative path)
- **stdin** — pipe / heredoc / paste

```bash
# inline — single key, fastest path for "is this key live?"
api-tester sk-proj-abc...

# inline — multiple keys
api-tester sk-ant-api03-... xai-... AIzaSy...

# default file mode — list /v1/models for each key, no token spend
api-tester keys.txt
api-tester ~/secrets/staging-keys.txt        # any path works

# only show the live ones, unmasked, with detected model ids
api-tester keys.txt --only valid --show-full --show-models

# JSON for piping into rotation/scripting
api-tester keys.txt --json | jq -r 'select(.status=="valid") | .key'

# stdin (one key per line)
pbpaste | api-tester                # macOS
xclip -o | api-tester               # linux/X11
wl-paste | api-tester               # wayland

# heredoc, no file
api-tester <<'EOF'
sk-...
sk-ant-...
EOF

# stress / verify retry behavior
api-tester keys.txt --retries 5 --concurrency 16

# actually invoke a model (spends 1 output token per key) — useful when /models
# doesn't reflect quota limits or org allowlists
api-tester keys.txt --model gpt-4o-mini
api-tester keys.txt --model claude-3-5-haiku-latest
api-tester keys.txt --model gemini-1.5-flash-latest
```

## Output schema (status column)

| Status         | Meaning                                                          |
| -------------- | ---------------------------------------------------------------- |
| `valid`        | Endpoint returned 2xx — key works.                               |
| `invalid`      | 400/401/403/404 — key is bad, revoked, wrong-tenant, or wrong endpoint. |
| `rate_limited` | 429 after retries exhausted — key may be live, can't tell now.   |
| `error`        | Network failure or 5xx after retries — try again later.          |

## Decision tree for the agent

1. User pastes keys or hands you `keys.txt`. Verify the file is in a
   gitignored location (or the repo's own `keys.txt` which is gitignored).
2. Run `api-tester <file>` (default = list-models, cheapest mode).
3. Read the summary line: `valid=N  invalid=N  rate_limited=N  error=N`.
4. For `valid` keys the user does **not** recognize, surface the rotation URL
   (in the api-tester README) and stop using the key.
5. For `rate_limited` or `error`, suggest re-running with `--retries 5` later.
6. If user needs proof a specific *model* works (not just the org token), rerun
   with `--model <name>` against just the live keys.

## Sister skills

- `security-review` — pre-step: find leaked keys in the repo first.
- `gh-fix-ci` — if a leaked key trips a secret-scanning push protection check.
- `obscura` / `defuddle` — unrelated, but live in the same skill catalog.

## Provenance

Authored 2026-05-10 from the local repo at `~/Documents/api-tester/`. The
upstream conceptual reference is `weiruchenai1/api-key-tester` (a web UI; this
skill drives the local CLI we wrote, no code copied). Re-check upstream before
adopting any of their newer features.
