---
name: codex-fleet-login
description: >-
  Use when user says "codex fleet login", "open kitty and run codex login", "log into codex accounts", "/codex-fleet-login", or wants to onboard one or more Codex CLI accounts by spawning kitty terminals (gx-fleet style), running `codex login`, capturing the OAuth URL, and opening it in the browser.
last_updated: "2026-05-13"
---

# Codex Fleet Login

Spawns one or more Kitty terminal windows, runs `codex login` in each, captures the OAuth authorization URL that `codex` prints, and opens it in the default browser. Mirrors the `gx cockpit` / gx-fleet pattern — uses Kitty remote control when available, otherwise spawns a fresh Kitty window.

## What it solves

`codex login` prints a long OAuth URL like:

```
https://auth.openai.com/oauth/authorize?response_type=code&client_id=app_EMoamEEZ73f0CkXaXp7hrann&...
```

and starts a local callback server on `http://localhost:1455`. For multi-account onboarding (the whole point of `codex-account-switcher`), users want one kitty window per account, the URL auto-opened, and the next account queued up after the current one finishes.

## Invocation

```bash
~/Documents/soul/skills/skills/orchestration/codex-fleet-login/codex_fleet_login.sh
```

Common flags:

| Flag | Default | What it does |
| ---- | ------- | ------------ |
| `--count N` | `1` | Spawn N windows sequentially (one at a time — port 1455 collides otherwise) |
| `--no-open` | open on | Print the URL but don't launch a browser |
| `--open-incognito` | default | Open the URL in a Chrome/Chromium **incognito** window (cache/extension-safe — fixes the "blank Loading… tab" bug) |
| `--open-default` | off | Use `xdg-open` (your default browser, normal profile) |
| `--label foo` | empty | Tag log filenames (`codex-login-<stamp>-foo-1.log`) |
| `--no-hold` | hold on | Auto-close the kitty window when `codex login` exits (default: keep it open until user presses Enter) |

### Why incognito by default

`codex login`'s consent page (`auth.openai.com/oauth/authorize?...`) has been observed to render as a blank tab in a hot Chrome profile — usually a cached service worker, an extension (uBlock/Privacy Badger), or stale auth.openai.com cookies. Incognito sidesteps all three. Codex itself also tries to auto-open the URL in your default browser; the incognito tab from this skill is a second tab that works even when the first one is stuck.

The script must be run from inside a graphical session (it spawns Kitty).

## Sequencing model

- One window at a time. `codex login` binds `localhost:1455`; two concurrent logins collide.
- Each window writes its output to `${TMPDIR:-/tmp}/codex-fleet-login/codex-login-<stamp>-<tag>.log`.
- The orchestrator polls that log for the OAuth URL (max 30s) and opens it.
- A `.done` marker file is written by the inner shell when `codex login` exits; the orchestrator waits for it (max 10 min — user time in the browser) before launching the next window.

## Kitty remote control vs. fresh window

- If `KITTY_LISTEN_ON` is exported **and** `kitty @ ls` succeeds, the script uses `kitty @ launch --type=os-window` (gx-cockpit style — child windows attach to the same host).
- Otherwise it shells out to `kitty bash -lc '...'` and detaches via `setsid` + `disown`.

To force gx-cockpit style, start the parent kitty with:

```bash
kitty -o allow_remote_control=yes -o listen_on=unix:/tmp/kitty-fleet.sock
```

and export `KITTY_LISTEN_ON=unix:/tmp/kitty-fleet.sock` before running the script.

## What gets logged

```
${TMPDIR:-/tmp}/codex-fleet-login/
├── codex-login-20260513-204512-1.log         # full codex login stdout
├── codex-login-20260513-204512-1.log.done    # marker, presence = process exited
└── ...
```

Logs are world-readable by default. They contain the OAuth URL (one-shot, expires quickly) and may contain account email metadata depending on the codex build. Treat as semi-sensitive — clean them with:

```bash
rm -rf "${TMPDIR:-/tmp}/codex-fleet-login"
```

## Troubleshooting

| Symptom | Cause | Fix |
| ------- | ----- | --- |
| "no OAuth URL within 30s" | `codex login` printed an error before the URL (port busy, network) | Check the kitty window; kill stale codex on `:1455` with `lsof -i :1455` |
| URL printed but browser didn't open | `xdg-open` missing or no GUI session | Re-run with `--no-open` and copy the URL manually |
| Kitty window doesn't appear | Running over SSH / no display | This skill needs a graphical session; use `codex login --device-auth` instead |
| Second account window never opens | First login still running — script waits for `.done` marker | Finish OAuth in the first browser tab, or kill that codex process |

## Adding to a codex-account-switcher workflow

When working in `~/Documents/recodee/codex-account-switcher`, this skill pairs with the existing snapshot/restore logic: log in fresh with this skill, then save the resulting `~/.codex/auth.json` via the switcher. The skill does not call into the switcher itself — keep concerns separated.

## Quick sanity check

```bash
test -x ~/Documents/soul/skills/skills/orchestration/codex-fleet-login/codex_fleet_login.sh && echo ok
command -v kitty && command -v codex && command -v xdg-open
echo "KITTY_LISTEN_ON=${KITTY_LISTEN_ON:-<unset>}"
```
