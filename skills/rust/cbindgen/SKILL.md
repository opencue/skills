---
name: cbindgen
description: Use when exposing a Rust library to C/C++ — auto-generate C headers from a Rust crate so other languages can link to it.
allowed-tools: Bash(cargo:*), Bash(cbindgen:*)
---

# cbindgen — Rust → C/C++ headers

The reverse of `bindgen`. Walks your `#[no_mangle] extern "C"` items and emits a header.

## When to use
- **Setup Cargo.toml**:
  ```toml
  [lib]
  crate-type = ["cdylib", "staticlib"]
  ```
- **Rust side** — annotate every exported item:
  ```rust
  #[no_mangle]
  pub extern "C" fn add(a: i32, b: i32) -> i32 { a + b }
  #[repr(C)]
  pub struct Point { x: f64, y: f64 }
  ```
- **Generate**: `cbindgen --config cbindgen.toml --crate mylib -o include/mylib.h`
- **Build-script flavor** (regenerates on every build):
  ```rust
  // build.rs
  let crate_dir = std::env::var("CARGO_MANIFEST_DIR").unwrap();
  cbindgen::Builder::new().with_crate(crate_dir).generate().unwrap().write_to_file("include/mylib.h");
  ```
- **cbindgen.toml** controls language (C or C++), include guards, namespace, type renames.

## Prerequisites
- cbindgen CLI (or build-dep)
- Rust items must be `#[no_mangle] pub extern "C"` with `#[repr(C)]` types

## Notes
- Only items reachable from `pub` and `extern "C"` are emitted — make sure they're not behind feature gates that aren't active at generation time.
- Pair with a `*.pc` (pkg-config) file or a small CMake `Find<Mylib>.cmake` so downstream C/C++ users can link cleanly.
- For C++-specific features (templates, namespaces), set `language = "C++"` in `cbindgen.toml`.
- Common pitfall: returning `String` or `Vec<T>` across FFI is UB — return `*mut c_char` / raw pointers with explicit free fns.
