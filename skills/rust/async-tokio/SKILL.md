---
name: async-tokio
description: Use when writing async Rust with tokio — picking a runtime flavor, structuring tasks, choosing sync vs async primitives, debugging deadlocks.
allowed-tools: Bash(cargo:*)
---

# Async Rust with Tokio

Runtime patterns + common foot-guns.

## When to use
- New binary: `#[tokio::main]` (multi-thread) or `#[tokio::main(flavor = "current_thread")]` for single-thread / WASM
- New lib: don't pull in tokio — return `impl Future` and let callers pick a runtime
- Spawn long-running task: `tokio::spawn(async move { ... })`
- Run blocking code: `tokio::task::spawn_blocking(|| ...)` — NEVER call blocking sync APIs (std::fs, std::thread::sleep) inside an async fn on the main runtime
- Cancel a task: drop the `JoinHandle` or use `tokio::select! { _ = cancel_rx => ..., r = work => ... }`
- Channels: `tokio::sync::mpsc` (multi-producer), `oneshot` (single message), `broadcast` (fanout), `watch` (latest-value)
- Async mutex only when you `.await` while holding the lock — otherwise use `std::sync::Mutex`

## Prerequisites
- cargo

## Notes
- Holding a `std::sync::Mutex` across `.await` is a clippy lint and a real deadlock risk. Use `tokio::sync::Mutex` or restructure to drop the guard first.
- `tokio::spawn` requires `Send` futures. For non-Send (e.g. tree-walking with `Rc`), use `tokio::task::spawn_local` + `LocalSet`.
- Debug deadlocks with `tokio-console` (separate crate) — it shows the live task tree.
- For libraries supporting multiple runtimes, gate runtime-specific code behind feature flags (`tokio`, `async-std`, `smol`) rather than pulling in tokio directly.
