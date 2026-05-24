---
name: cross-compile
description: Use when building a Rust binary for a different target — ARM, musl, Windows, Android — without setting up native toolchains.
allowed-tools: Bash(cargo:*), Bash(cross:*), Bash(rustup:*), Bash(docker:*)
---

# cross — zero-fuss cross-compilation

Wraps Docker containers with the right linkers/sysroots so you don't deal with them.

## When to use
- Static musl binary (deploy to Alpine / scratch container): `cross build --release --target x86_64-unknown-linux-musl`
- aarch64 (Raspberry Pi, ARM server): `cross build --release --target aarch64-unknown-linux-gnu`
- Windows from Linux/Mac: `cross build --release --target x86_64-pc-windows-gnu`
- Test on a non-native target: `cross test --target <triple>`
- Custom toolchain: `Cross.toml` at repo root to pin image / env vars

## Prerequisites
- cross (`cargo install cross --git https://github.com/cross-rs/cross`)
- Docker (or Podman with `CROSS_CONTAINER_ENGINE=podman`)
- The target installed once: `rustup target add <triple>` (cross handles the rest)

## Notes
- For `wasm32-unknown-unknown` use cargo directly with `--target` — cross isn't needed.
- musl builds are larger statically; strip with `strip` or `[profile.release] strip = true`.
- macOS targets from Linux are NOT supported by cross (licensing). Use a real Mac or GitHub Actions runner.
