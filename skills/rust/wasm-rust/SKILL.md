---
name: wasm-rust
description: Use when building Rust → WASM — modules with JS bindings (wasm-pack), full SPA frontends (trunk + Yew/Leptos/Sycamore), or Dioxus apps.
allowed-tools: Bash(cargo:*), Bash(wasm-pack:*), Bash(trunk:*), Bash(dioxus:*), Bash(rustup:*)
---

# Rust → WebAssembly

Pick the toolchain that matches the target.

## When to use
- **Library for JS to consume** (npm, web, node, deno): `wasm-pack build --target web|nodejs|bundler`
  - Generates `pkg/` with `.wasm`, `.js`, `.d.ts`, `package.json`
  - Use `#[wasm_bindgen]` on exported fns/structs
- **Full Rust SPA** (Yew, Leptos, Sycamore): `trunk serve` (dev) · `trunk build --release` (prod)
  - Entry is `index.html` with a `<link data-trunk rel="rust" />`
- **Dioxus app** (web/desktop/mobile from one codebase): `dx new <name>` · `dx serve --platform web`

## Prerequisites
- WASM target: `rustup target add wasm32-unknown-unknown`
- wasm-pack, trunk, or dioxus-cli depending on path

## Notes
- For web SPAs, `wasm-opt` (from binaryen) shaves significant size — trunk runs it automatically in `--release`.
- `wee_alloc` saves ~10KB but is unmaintained; the default allocator is usually fine.
- Async works in browser via `wasm-bindgen-futures`; spawn with `spawn_local`.
- Cargo features: gate native-only code behind `#[cfg(not(target_arch = "wasm32"))]` so the WASM build doesn't pull in tokio's mio.
