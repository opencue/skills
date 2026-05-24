---
name: bindgen
description: Use when calling C libraries from Rust — auto-generate FFI signatures from C headers instead of hand-typing extern blocks.
allowed-tools: Bash(cargo:*), Bash(bindgen:*)
---

# bindgen — C → Rust FFI

Reads C headers via libclang, emits `extern "C" { ... }` blocks + struct layouts.

## When to use
- **One-off generation**:
  ```sh
  bindgen wrapper.h -o src/bindings.rs --allowlist-function 'foo_.*' --allowlist-type 'Foo.*'
  ```
- **Build-script integration** (regenerates on header change):
  ```rust
  // build.rs
  fn main() {
      println!("cargo:rustc-link-lib=mylib");
      let bindings = bindgen::Builder::default()
          .header("wrapper.h")
          .parse_callbacks(Box::new(bindgen::CargoCallbacks::new()))
          .generate().unwrap();
      bindings.write_to_file(std::path::PathBuf::from(std::env::var("OUT_DIR").unwrap()).join("bindings.rs")).unwrap();
  }
  ```
  Then `include!(concat!(env!("OUT_DIR"), "/bindings.rs"));` in your lib.rs.
- **Vendored vs system libs**: pair with `pkg-config` crate or `cmake` crate to find/build the underlying C library.

## Prerequisites
- bindgen CLI (or `bindgen` build-dep)
- `libclang` (`apt install libclang-dev` / `brew install llvm` + `LIBCLANG_PATH`)

## Notes
- Always wrap unsafe FFI in a safe Rust API in the same crate — downstream users should never write `unsafe { ffi::* }`.
- Use `--allowlist-*` aggressively. Generating bindings for ALL of `stdio.h` produces hundreds of unused items.
- For C++ libraries: bindgen has partial support; for serious C++ interop use `cxx` crate (different model).
- Pre-built `*-sys` crates already exist for most popular C libs (e.g. `libgit2-sys`, `libz-sys`) — check crates.io before rolling your own.
