---
name: uniffi
description: Use when exposing one Rust library to multiple languages (Kotlin/Swift/Python/Ruby) from a single UDL spec. Mozilla's approach; used by Bitwarden, Matrix SDK.
allowed-tools: Bash(cargo:*), Bash(uniffi-bindgen:*)
---

# UniFFI — one Rust → many languages

Write the interface once (`.udl` or proc-macro), generate idiomatic Kotlin/Swift/Python/Ruby bindings. Avoids hand-writing JNI/JNA + Swift-C-bridge + ctypes for each platform.

## When to use
- **Proc-macro flavor** (newer, no .udl file):
  ```rust
  #[uniffi::export]
  pub fn add(a: i32, b: i32) -> i32 { a + b }
  uniffi::setup_scaffolding!();
  ```
  Cargo.toml: `crate-type = ["cdylib", "staticlib"]` + `uniffi` dep + `[build-dependencies] uniffi = { features = ["build"] }`
- **Generate bindings**:
  ```sh
  cargo build --release
  uniffi-bindgen generate --library target/release/libmylib.so --language kotlin --out-dir out/kotlin
  uniffi-bindgen generate --library ... --language swift   --out-dir out/swift
  uniffi-bindgen generate --library ... --language python  --out-dir out/python
  ```
- **iOS**: build for `aarch64-apple-ios` + `x86_64-apple-ios-sim` + lipo into XCFramework
- **Android**: `cargo-ndk` to cross-compile for `aarch64-linux-android` etc.

## Prerequisites
- cargo
- uniffi-bindgen CLI (`cargo install uniffi-bindgen`)
- Per-target toolchains for the languages you generate

## Notes
- Mature & production-proven (Mozilla, Bitwarden, Matrix SDK ship UniFFI bindings).
- Type support is opinionated — primitives, strings, Vec, Option, HashMap, custom records/enums. Closures and traits work but with caveats.
- For one-target FFI (just Python), prefer PyO3 or just Node, prefer napi-rs — UniFFI shines when you need ≥2 targets from one codebase.
- The proc-macro flavor is now stable; new projects shouldn't use UDL files.
