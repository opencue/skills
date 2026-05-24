---
name: no-std
description: Use when writing Rust without the standard library — embedded, WASM, kernel, bootloader, or library code that must work in `no_std` consumers.
allowed-tools: Bash(cargo:*)
---

# `#![no_std]` — Rust without std

`std` = `core` + `alloc` + OS bindings. Removing std loses heap allocation, threads, file I/O, and networking. You keep types, iterators, slices, traits.

## When to use
- **Mark the crate**: `#![no_std]` at the top of `lib.rs` or `main.rs`
- **Use `core::*` and `alloc::*`** instead of `std::*`:
  ```rust
  use core::fmt::Write;
  extern crate alloc;
  use alloc::{vec::Vec, string::String, boxed::Box};
  ```
- **Provide an allocator** (if you want `alloc`): `#[global_allocator] static A: MyAlloc = MyAlloc;` (heap crate per target, e.g. `embedded-alloc` for Cortex-M)
- **Panic handler**: pick one and add as a dep — `panic-halt`, `panic-abort`, or roll your own `#[panic_handler] fn panic(_: &PanicInfo) -> ! { loop {} }`
- **Cargo features for std/no-std libraries**:
  ```toml
  [features]
  default = ["std"]
  std = []
  ```
  Then in code: `#![cfg_attr(not(feature = "std"), no_std)]`
- **Common substitutes**:
  - `std::collections::HashMap` → `hashbrown::HashMap` (with `alloc`) or fixed-size `heapless::IndexMap`
  - `std::sync::Mutex` → `spin::Mutex` (spinlock) or `critical-section::Mutex` (interrupt-safe)
  - `std::format!` → `heapless::String` + `core::fmt::Write` (no allocations)
  - `std::error::Error` → not in core; use `core::error::Error` (stable 1.81+) or `snafu`/`thiserror-no-std`

## Prerequisites
- cargo
- A target without std (or std intentionally excluded): `wasm32-unknown-unknown`, any `thumbv*`, `riscv*-none-elf`

## Notes
- **Audit deps**: many crates have a `default-features = false` flag that disables std — set it explicitly. `cargo tree -e features` shows where std leaks back in.
- `heapless` crate provides `Vec<T, N>` and `String<N>` with const-generic capacity — no allocator needed.
- For libraries published to crates.io, gating `std` behind a feature is the polite default — downstream embedded users will love you.
- WASM `wasm32-unknown-unknown` has no OS, so `std::fs` / `std::net` / `std::thread` panic at runtime even though they compile. Treat as effectively no_std.
