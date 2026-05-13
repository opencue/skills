---
name: kitty-visualize
description: Use when user asks to "visualize", "show me", "draw", "render", "diagram", "picture this", "layout", or "open in kitty/another window" — and the artifact is a diagram, ASCII layout, tmux/fleet picture, dependency graph, or image preview. Renders the artifact to a temp file and opens it in a detached kitty terminal window so it does NOT clutter the chat. Default surface for any visualization request from this user.
metadata:
  type: design-tool
---

# kitty-visualize

The user wants visualizations on a **separate kitty window**, not inline in the chat.

Default rule: when a user request resolves to producing a diagram, ASCII layout, dependency graph, tmux/pane picture, fleet topology, or image preview — **do not** dump it in the chat response. Render it to a temp file under `/tmp/claude-viz/` and spawn a detached kitty window pointed at that file. Confirm in chat with ONE short line containing the path.

## When the trigger fires

User intent keywords:
- "visualize", "visualization", "show me a diagram", "draw it"
- "render", "picture", "layout", "topology"
- "open it in kitty", "another window", "not in the chat"
- Any explicit "make me a chart / diagram / graph"

If the user wants a **textual** answer with a small inline ASCII sketch (e.g. "what does the dir tree look like" → 5 lines of tree), keep it inline — that is not a visualization. The skill applies when the artifact is the *point*.

## How to render

### 1. Pick the artifact type

| Artifact | File ext | Viewer |
| --- | --- | --- |
| ASCII / Unicode diagram | `.txt` | `kitty --hold less -R <file>` |
| Markdown with code blocks | `.md` | `kitty --hold less -R <file>` (or glow if available) |
| Single image (PNG, JPG, SVG) | `.png` / `.svg` | `kitty +kitten icat --hold <file>` |
| Mermaid / Graphviz source | render first with `mmdc` / `dot -Tpng`, then icat | |

For ASCII layouts (the most common case here) **always use the `.txt` path** — readable in less, scrollable, copy-friendly.

### 2. Write the file

```bash
mkdir -p /tmp/claude-viz
TS=$(date +%Y%m%d-%H%M%S)
FILE=/tmp/claude-viz/viz-${TS}-<short-label>.txt
cat > "$FILE" <<'EOF'
<diagram content>
EOF
```

Pick a short kebab-case label that describes the picture (`fleet-panes`, `ph13-waves`, `coolify-topology`). Never overwrite an existing viz file — the timestamp prevents that.

### 3. Spawn kitty detached

```bash
setsid kitty --title "claude-viz: <label>" --hold \
  less -R "$FILE" </dev/null >/dev/null 2>&1 &
disown 2>/dev/null || true
```

Why each flag:
- `setsid` + `&` + `disown` — detach so kitty survives the parent shell exiting.
- `--title` — so the user can find the window in their taskbar / picker.
- `--hold` — keep the window open after `less` exits (Ctrl-C, `q`).
- `less -R` — `-R` passes ANSI colors through (box-drawing chars and color codes both render).
- `</dev/null` — don't inherit the agent shell's stdin.

If kitty is **not on PATH**, fall back to printing a single-line: `"kitty not installed; saved to $FILE"` and exit — do NOT inline-dump the diagram.

### 4. Confirm in chat

One line, no preview:

```
kitty window opened: <FILE>
```

That's it. No "here's what I drew", no inline copy of the same diagram, no markdown headings.

## What NOT to do

- Do not also paste the diagram into the chat. The whole point is to keep chat clean.
- Do not open kitty *attached* (foreground) — it would block the agent shell and the user's terminal.
- Do not use temp files outside `/tmp/claude-viz/`; that directory is the agreed parking lot.
- Do not pre-clean `/tmp/claude-viz/` between turns. The user may want to re-open an older viz.
- Do not call `kitty +kitten icat` for plain ASCII text — `less -R` is faster and scrollable.
- Do not invent diagrams when the user asks a textual question. Trigger ONLY when the artifact is what they want.

## Examples

**User**: "visualize the fleet panes"
→ write `/tmp/claude-viz/viz-20260513-222600-fleet-panes.txt` with the 6-pane grid
→ `setsid kitty --title "claude-viz: fleet-panes" --hold less -R … &`
→ chat: `kitty window opened: /tmp/claude-viz/viz-20260513-222600-fleet-panes.txt`

**User**: "show me the ph13/14/15 dep graph in another window"
→ write `.txt` with the wave-by-wave dependency graph
→ spawn kitty as above
→ chat: one line

**User**: "what files are in this dir?"
→ Not a visualization. Reply textually. Do NOT trigger this skill.

**User**: "render the coolify topology as an image"
→ Use `dot -Tpng` → `kitty +kitten icat --hold` flow.

## Cleanup

The user owns `/tmp/claude-viz/`. Don't remove anything from it. If they ask to clean up, suggest `rm /tmp/claude-viz/viz-*.txt` and let them run it.
