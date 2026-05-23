---
description: "When user asks to record a high-quality CLI demo GIF that needs Kitty graphics protocol (real PNG icons inline) — use this headless Xvfb + Kitty + tmux + ffmpeg pipeline instead of vhs/asciinema which don't speak the Kitty protocol"
requires_mcps: []
allowed-tools: Bash(Xvfb:*), Bash(kitty:*), Bash(tmux:*), Bash(xdotool:*), Bash(ffmpeg:*), Bash(/usr/bin/ffmpeg:*), Read(*), Write(*)
---

# Headless GIF demos with Kitty + tmux + Xvfb + ffmpeg

When you need a demo GIF of a CLI tool that uses **Kitty graphics protocol** (e.g. cue's brand-logo PNGs in `cue optimizer`), `vhs` and `asciinema` won't work — they render in `ttyd` which doesn't speak the protocol. Logos show as garbled placeholder boxes or fall back to emoji.

This skill captures the working pipeline: spin up a virtual X display, run real Kitty inside it (no monitor needed), drive the demo with `tmux send-keys`, and screen-record with `ffmpeg x11grab`.

## When to use

- ✅ Demo of a CLI that uses Kitty graphics (inline images, brand logos, plots)
- ✅ Demo of a TUI that depends on truecolor + Unicode + Nerd Font glyphs
- ✅ Demo that must show interactive prompts (pickers, confirmations)
- ❌ Plain shell-output demos → use `vhs` (simpler, no X needed)
- ❌ Real session recordings → use `asciinema` (escape-sequence based)

## Required tools

| Tool | Install (apt) | Install (nix) |
|---|---|---|
| `Xvfb` | `sudo apt install xvfb` | `nix profile install nixpkgs#xorg.xorgserver` |
| `xdotool` | `sudo apt install xdotool` | `nix profile install nixpkgs#xdotool` |
| `ffmpeg` with `x11grab` | `sudo apt install ffmpeg` (**not** nix-pure ffmpeg — that one lacks x11grab) | `nix profile install nixpkgs#ffmpeg-full` |
| `kitty` | already on your box | — |
| `tmux` | already on your box | — |

**Gotcha:** verify ffmpeg has x11grab with `ffmpeg -devices | grep x11`. nix's stock `ffmpeg` doesn't ship it — use `/usr/bin/ffmpeg` (apt) or `ffmpeg-full` (nix).

## The pipeline

```
Xvfb :99 → kitty (--start-as=fullscreen, attached to tmux session)
              ↓
        tmux send-keys (drives demo non-interactively)
              ↓
        ffmpeg x11grab :99 (records the virtual display to mp4)
              ↓
        ffmpeg palettegen + paletteuse (2-pass → sharp gif)
```

## Key parameters that matter

1. **Strip cue/claude env vars before launching the inner shell** — `unset CUE_LAUNCHING CLAUDE_CONFIG_DIR CLAUDECODE CLAUDE_CODE_SESSION_ID CLAUDE_EFFORT AI_AGENT CODEX_HOME`. Otherwise the shim's recursion guard fires the moment you type `claude`.

2. **PATH ordering inside the inner shell.** `~/.local/bin` (shim) must come first so `claude` resolves to the shim; the real binary (e.g. `~/.nvm/versions/node/<v>/bin`) must come next so `cue launch` can `exec` it. nvm-installed binaries are NOT inherited by ttyd's bash — set PATH explicitly.

3. **tmux passthrough for Kitty graphics.** Inner tmux config needs:
   ```
   set -g allow-passthrough on
   set -g default-terminal "xterm-kitty"
   set -as terminal-features ",xterm-kitty:RGB"
   ```
   Plus `export TERM=xterm-kitty` and `export CUE_KITTY=1` inside the tmux pane so cue uses the kitty path through tmux.

4. **Kitty must fill the Xvfb display.** Use `--start-as=fullscreen` (no WM needed). If that fails on a minimal Xvfb, `xdotool search --class <cls> windowsize <W> <H>` as a fallback. Without this, kitty opens at 80×24 in a corner and ffmpeg captures mostly blank pixels — the GIF comes out ~20 KB instead of ~1 MB.

5. **Kitty option values are raw — never `px`.** `--override initial_window_width=1500`, not `1500px`. The parser rejects the suffix and kitty silently fails to start; xdotool then finds no window and ffmpeg records the empty Xvfb root.

6. **Verify before recording.** After kitty launches, grab a single frame:
   ```bash
   DISPLAY=:99 xwd -root | convert xwd:- /tmp/preflight.png
   ```
   If `/tmp/preflight.png` is solid color → kitty isn't on Xvfb. If it shows your terminal → start ffmpeg.

7. **Pickers ask twice.** After Enter selects a profile, cue's picker shows a second "Pin to this directory? Yes/No" prompt. Need a second Enter to confirm or your demo hangs.

## Skeleton script

See [`scripts/record-demo-kitty.sh`](../../../../../scripts/record-demo-kitty.sh) for the complete working version. Structure:

```bash
#!/usr/bin/env bash
set -euo pipefail

DISPLAY_NUM=:99
WIDTH=1500; HEIGHT=900
FFMPEG=/usr/bin/ffmpeg            # the apt build — has x11grab

# 1. virtual display
Xvfb $DISPLAY_NUM -screen 0 ${WIDTH}x${HEIGHT}x24 &
XVFB_PID=$!
trap "kill $XVFB_PID 2>/dev/null" EXIT
sleep 1.5

# 2. tmux config + detached session
cat > /tmp/tmux.conf <<'EOF'
set -g allow-passthrough on
set -g default-terminal "xterm-kitty"
set -g status off
EOF
DISPLAY=$DISPLAY_NUM tmux -L demo -f /tmp/tmux.conf \
  new-session -d -s d -x $((WIDTH/10)) -y $((HEIGHT/22)) \
  "cd /tmp/cue-demo && bash --noprofile --norc -i"

SEND() { tmux -L demo send-keys -t d "$@"; }
SEND 'unset CUE_LAUNCHING CLAUDE_CONFIG_DIR CLAUDECODE' Enter
SEND 'export PATH="$HOME/.local/bin:$HOME/.nvm/versions/node/v22.22.0/bin:$PATH"' Enter
SEND 'export TERM=xterm-kitty CUE_KITTY=1' Enter
SEND 'clear' Enter
sleep 0.5

# 3. real kitty on the virtual display
DISPLAY=$DISPLAY_NUM kitty \
  --class cue-demo --start-as=fullscreen \
  --override font_family="JetBrainsMono Nerd Font" \
  --override font_size=14 \
  --override initial_window_width=$WIDTH \
  --override initial_window_height=$HEIGHT \
  -- tmux -L demo attach -t d &
sleep 2.5

# 4. preflight
DISPLAY=$DISPLAY_NUM xwd -root | convert xwd:- /tmp/preflight.png
echo "preflight: $(identify -format '%[mean]' /tmp/preflight.png) mean intensity"

# 5. record
$FFMPEG -y -f x11grab -video_size ${WIDTH}x${HEIGHT} -framerate 15 \
  -i $DISPLAY_NUM -t 40 -c:v libx264 -preset ultrafast -pix_fmt yuv420p \
  /tmp/raw.mp4 &
FFMPEG_PID=$!
sleep 1

# 6. drive the demo
SEND 'cue optimizer readme-writer' Enter
sleep 7
SEND 'claude' Enter
sleep 3
for i in $(seq 1 14); do SEND Down; sleep 0.08; done
sleep 0.7
SEND Enter           # selects profile
sleep 1.6
SEND Enter           # answers "Pin to this directory? Yes" prompt
sleep 7

wait $FFMPEG_PID

# 7. 2-pass mp4 → gif (sharp colors)
$FFMPEG -y -i /tmp/raw.mp4 \
  -vf "fps=12,scale=1200:-1:flags=lanczos,palettegen=stats_mode=diff" \
  /tmp/palette.png
$FFMPEG -y -i /tmp/raw.mp4 -i /tmp/palette.png \
  -lavfi "fps=12,scale=1200:-1:flags=lanczos [x]; [x][1:v] paletteuse=dither=bayer:bayer_scale=4" \
  docs/assets/demo.gif
```

## Sanity check the output

Healthy capture:
- raw mp4 ≥ 500 KB for ~30 s recording
- output gif 400 KB – 2 MB
- `ffmpeg -i raw.mp4` reports bitrate in the hundreds of kbps, not single digits

Pathological capture (means kitty didn't render to Xvfb):
- raw mp4 < 50 KB (4 kbps bitrate is the smoking gun)
- gif comes out 10–20 KB
- single extracted frame compresses to a few KB (solid color)

## Workflow

1. Verify tools: `which Xvfb xdotool kitty tmux && /usr/bin/ffmpeg -devices | grep x11`
2. Copy the skeleton from [`scripts/record-demo-kitty.sh`](../../../../../scripts/record-demo-kitty.sh) — adapt the demo commands
3. Test-run; check the preflight screenshot is non-empty
4. Iterate on timing — pickers and Claude Code splash both need 2–3 s headroom
5. Commit both the script and the resulting GIF — re-running gives byte-identical output for a fixed tape
