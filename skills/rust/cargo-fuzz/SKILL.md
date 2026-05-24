---
name: cargo-fuzz
description: Use when fuzzing parsers, deserializers, FFI boundaries, or any code that takes untrusted bytes. libFuzzer integration via cargo-fuzz.
allowed-tools: Bash(cargo:*), Bash(cargo-fuzz:*), Bash(rustup:*)
---

# cargo-fuzz — libFuzzer for Rust

Coverage-guided fuzzing. Often finds panics + UB within minutes on parser code.

## When to use
- **Init in a crate**: `cargo fuzz init`
- **Add a target**: `cargo fuzz add my_parser` — generates `fuzz/fuzz_targets/my_parser.rs`
- **Target body**:
  ```rust
  libfuzzer_sys::fuzz_target!(|data: &[u8]| {
      let _ = my_crate::parse(data);  // must not panic
  });
  ```
- **Run** (requires nightly): `cargo +nightly fuzz run my_parser`
- **Reproduce a crash**: `cargo +nightly fuzz run my_parser fuzz/artifacts/my_parser/crash-*`
- **Minimize crashes**: `cargo +nightly fuzz tmin my_parser <artifact>`
- **Seed corpus**: drop interesting inputs in `fuzz/corpus/my_parser/`

## Prerequisites
- nightly: `rustup install nightly`
- cargo-fuzz
- libFuzzer ships with nightly's compiler-rt — no extra package on Linux/macOS

## Notes
- Run continuously in the background, not as a unit test — fuzzing is a long-running search.
- Pair with `arbitrary` crate so target bodies parse `&[u8]` into structured types: `fuzz_target!(|input: MyStruct| ...)` via `#[derive(Arbitrary)]`.
- Commit interesting corpus inputs + any minimized crashes — they accelerate the next run.
- For HTTP server fuzzing, look at `cargo-bolero` (multi-engine wrapper) instead.
