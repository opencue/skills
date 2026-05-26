---
name: cue-rec
description: |
  Record the current desktop/terminal session to a video for marketing,
  demos, or sharing a flow. Wraps GNOME Shell's built-in Screencast over
  D-Bus on Wayland (no extra deps beyond ffmpeg + slurp).
  Use when the user says "record this session", "screencast this",
  "make a marketing video", "make a demo video", "start recording",
  "stop the recording", "capture this flow", or invokes /cue-rec.
triggers:
  - record this session
  - record my screen
  - screencast this flow
  - make a marketing video
  - make a demo video
  - start recording
  - stop recording
  - capture this flow
  - /cue-rec
tags: [marketing, video, demo, screencast, wayland, gnome]
category: marketing
version: 1.0.0
requires_mcps: []
allowed-tools: Bash
---

# cue-rec — record sessions for marketing

Start/stop a desktop video recording from the CLI. Built on
`org.gnome.Shell.Screencast` (D-Bus), so it works natively on Ubuntu
GNOME Wayland with no extra installs. A tiny Python helper holds the
bus connection open for the duration of the recording — without it,
GNOME tears the screencast down when the calling `gdbus` exits
("Sender has vanished" in the journal).

## When to activate

- User wants to record their desktop or terminal for a demo / marketing clip
- User says "record this session", "screencast this", "make a marketing video",
  "make a demo video", "start recording", "stop recording", "/cue-rec"
- User asks to capture a flow they're about to perform

Don't activate for:
- Asciicast/terminal-only recording (suggest `asciinema` separately if they
  want terminal-only — `cue-rec` captures the actual desktop pixels)
- Audio-only recording

## Commands

The binary lives at `${CLAUDE_SKILL_DIR}/bin/cue-rec` and is also symlinked
to `~/.local/bin/cue-rec`, so prefer the on-PATH form:

### Pixel capture (mp4/webm via GNOME Screencast)
```bash
cue-rec targets                  # list monitors with index + geometry
cue-rec start --monitor N        # capture monitor N (1920×1080 etc — clean files)
cue-rec start --kitty            # capture the current kitty window
                                 #   X11: auto-detected via xdotool
                                 #   Wayland: falls back to slurp + helpful prompt
cue-rec start --area             # drag a region with slurp (any window)
cue-rec start --geom X,Y,WxH     # explicit geometry (e.g. 0,0,1920x1080)
cue-rec start --pick             # interactive menu (terminal only)
cue-rec start                    # full multi-monitor screen
cue-rec start --name demo        # add a label (combine with any of the above)
cue-rec stop                     # finalize, prints the path
cue-rec status                   # idle | recording + elapsed
cue-rec list                     # everything in ~/Videos/cue-rec/
cue-rec play [FILE]              # open latest (or named file) in VLC/mpv
cue-rec gif FILE [OUT.gif]       # palette-optimized gif (README/social)
cue-rec mp4 FILE [OUT.mp4]       # x264 mp4 with faststart (uploads)
```

### Terminal-only capture (asciinema .cast — text, not pixels)
```bash
cue-rec term --name demo         # record this shell as a .cast (type `exit` to stop)
cue-rec term-play [FILE]         # replay a .cast inline in this terminal
cue-rec term-gif FILE.cast       # convert .cast → gif (needs `agg`)
```

**When to use which:** `term` for CLI marketing (README demos, social posts,
Twitter, blog embeds) — tiny files, crisp text, scalable. `start --kitty`
when you need actual pixels (TUI animations, color faithfulness, demos that
include GUI windows spawned from the terminal).

**Codec note:** GNOME outputs `.webm/VP8` for full-screen captures and
`.mp4/H.264` for region/monitor captures (the screencast pipeline differs).
Either plays cross-platform, but if the file is `.webm` and the target
player chokes on OpenGL with a too-wide texture (>4096px), run
`cue-rec mp4 FILE` to transcode and downscale.

If `cue-rec` is not on PATH for some reason, fall back to:

```bash
bash "${CLAUDE_SKILL_DIR}/bin/cue-rec" start
```

## House style for marketing clips

- **Never default to full multi-monitor.** Always ask the user (via
  `AskUserQuestion` if running from Claude Code) which monitor to record,
  or use `--area` for tight window framing. Full-screen multi-monitor
  produces files wider than 4096 px that crash GL-based players like Totem.
- **Recommend `--monitor N` first** when capturing a single display.
  Faster than slurp, deterministic, and the output is already H.264 mp4.
- **Use `--area` for sub-window captures** (e.g., only the kitty pane,
  not the whole monitor). Run `cue-rec targets` first if Claude needs to
  enumerate options.
- **Name the take.** `cue-rec start --monitor 2 --name cue-launch` so
  files are searchable: `~/Videos/cue-rec/<timestamp>-<name>.{webm,mp4}`.
- **Don't leak secrets.** If the recording captured tokens or `.env`
  output, follow up with `mcp__cue-tty-watch__redact_video` before sharing.

## Claude-Code-driven selection (preferred when this skill activates)

When the user invokes this skill from Claude Code, **do not** default to
full screen. Instead:

1. Run `cue-rec targets` to enumerate monitors.
2. Ask via `AskUserQuestion`: which monitor, and how long (10s / 30s / 60s
   / wait-for-stop).
3. Run `cue-rec start --monitor N --name <slug>`, sleep for the duration
   (or wait for an explicit "stop"), then `cue-rec stop`.
4. Report the final path. If the file is webm and wider than 3840 px,
   offer `cue-rec mp4` with downscale.

## Architecture (one-line per piece)

- `bin/cue-rec` — bash CLI: arg parsing, slurp for region, state file at
  `~/.cache/cue-rec/current`, output dir `~/Videos/cue-rec/`.
- `bin/cue-rec-daemon` — Python 3 / PyGObject helper. Calls
  `Screencast` / `ScreencastArea` over D-Bus, writes `OK <pid> <file>`
  to a status file the CLI polls, then blocks in a GLib mainloop until
  SIGTERM/SIGINT, at which point it calls `StopScreencast` and exits 0.

Override the output directory with `CUE_REC_DIR=/path/to/dir`. State and
logs live under `$XDG_CACHE_HOME/cue-rec/` (defaults to `~/.cache/cue-rec/`).

## Requirements

- GNOME Shell on Wayland (works out of the box on Ubuntu 22+/24+).
- `gdbus`, `python3` with `gi` (PyGObject) — system-installed on Ubuntu.
- `slurp` (Wayland region picker) — only needed for `--area`.
- `ffmpeg` — only needed for `gif` / `mp4` post-processing.

## Failure modes

| Symptom | Likely cause | Fix |
|---|---|---|
| `daemon did not confirm start within 5s` | GNOME's screencast service isn't responding | `gdbus call --session --dest org.gnome.Shell.Screencast --object-path /org/gnome/Shell/Screencast --method org.freedesktop.DBus.Properties.Get org.gnome.Shell.Screencast ScreencastSupported` should return `true` |
| `stopped, but file not flushed yet` | Mutter is still muxing; very short recording or busy GPU | Wait 1-2s, re-`ls`. If still empty, check `~/.cache/cue-rec/daemon.log` |
| Recording is black / blank | Another screencast client (OBS, Flameshot) was holding the pipewire stream | Close the other client, restart GNOME Shell session |
| Region picker exits immediately | `slurp` not installed | `sudo apt install slurp` |
| Not GNOME / not Wayland | Different compositor | Use `wf-recorder` (wlroots) or `ffmpeg -f x11grab` (X11) instead — `cue-rec` is GNOME-specific |
