---
name: ratatui-tui
description: Use when building a Rust terminal UI (TUI) — dashboards, file managers, monitors. Covers ratatui (the standard) + crossterm.
allowed-tools: Bash(cargo:*)
---

# ratatui — Rust TUI framework

Successor to `tui-rs`. Powers `bottom`, `gitui`, `atuin`, `oha`, `lazygit`'s Rust clones, etc.

## When to use
- **Setup**: `ratatui = "0.28"`, `crossterm = "0.28"` (default backend)
- **Skeleton**:
  ```rust
  let mut terminal = ratatui::init();
  loop {
      terminal.draw(|f| ui(f, &state))?;
      if let Event::Key(k) = crossterm::event::read()? { handle(k, &mut state); }
      if state.should_quit { break; }
  }
  ratatui::restore();
  ```
- **Widgets**: `Block`, `Paragraph`, `List`, `Table`, `Gauge`, `Chart`, `Tabs`, `Sparkline`, `Canvas`
- **Layout**: `Layout::new(Direction::Vertical, [Constraint::Length(3), Constraint::Min(0)])`
- **State**: stateful widgets (`ListState`, `TableState`) — pass `&mut state` to `render_stateful_widget`
- **Async**: spawn a `tokio` task that pushes events into an mpsc; the render loop selects between input + tick + app events

## Prerequisites
- cargo
- crates: `ratatui`, `crossterm`

## Notes
- Always pair `ratatui::init()` with `ratatui::restore()` — set a panic hook to call `restore()` or your terminal stays in raw mode after a crash.
- Don't redraw every event — throttle to ~30-60 fps or only on dirty state. Otherwise input latency degrades on slow terminals.
- For complex apps, look at `tui-realm` (component model) or `cursive` (different paradigm, less popular).
- Test renders with `ratatui::backend::TestBackend` — captures the buffer for snapshot assertions.
