---
name: napi-rs
description: Use when exposing Rust to Node.js — write a native addon via N-API. The path NextSwc, Parcel, and Prisma's query engine take.
allowed-tools: Bash(cargo:*), Bash(napi:*), Bash(npm:*), Bash(node:*)
---

# napi-rs — Rust → Node.js native addons

Stable ABI (N-API), no rebuild on Node version bumps. Cross-platform binaries shipped via per-platform npm packages.

## When to use
- **Init**: `npx @napi-rs/cli new my-addon` (asks for target platforms, tooling)
- **Expose a fn**:
  ```rust
  use napi_derive::napi;
  #[napi] fn sum(a: i32, b: i32) -> i32 { a + b }
  #[napi] async fn read_file(path: String) -> napi::Result<String> { Ok(tokio::fs::read_to_string(path).await?) }
  ```
- **Build local**: `napi build --platform --release`
- **Run JS**: `import { sum } from './index.js'; console.log(sum(2,3));`
- **Multi-platform release**: GitHub Actions matrix builds per-target binaries; CLI publishes platform-suffixed packages (`@scope/my-addon-linux-x64-gnu`) plus a parent that picks the right one at install time.
- **TypeScript**: `.d.ts` is auto-generated from `#[napi]` annotations

## Prerequisites
- cargo
- Node 16+ and npm/pnpm/yarn
- `@napi-rs/cli` (npm install -g or via npx)

## Notes
- Async functions return Promises automatically — no manual `napi::JsFunction` wrapping needed.
- The N-API surface is small but stable; you don't get full V8 access (use `neon` if you need that, but neon is less stable across Node versions).
- For pure-JS interop without native addons, look at `wasm-bindgen` + `wasm-pack --target nodejs` — slower but no per-platform binaries.
