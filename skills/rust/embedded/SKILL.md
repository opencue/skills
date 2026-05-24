---
name: embedded
description: Use when flashing, debugging, or developing for microcontrollers in Rust (Cortex-M, RISC-V, ESP32). Covers probe-rs, cargo-embed, defmt, embassy async runtime.
allowed-tools: Bash(cargo:*), Bash(probe-rs:*), Bash(cargo-embed:*), Bash(cargo-binutils:*), Bash(rustup:*)
---

# Rust embedded — probe-rs + embassy

Modern Rust embedded stack: probe-rs replaces OpenOCD, defmt replaces printf, embassy provides async on bare metal.

## When to use
- **Target setup** (Cortex-M example): `rustup target add thumbv7em-none-eabihf` (M4F) or `thumbv6m-none-eabi` (M0)
- **Project layout**: `no_std` binary crate; `[build] target = "thumbv7em-none-eabihf"` in `.cargo/config.toml`
- **HAL** (Hardware Abstraction Layer): pick per chip — `stm32f4xx-hal`, `rp2040-hal`, `esp-hal`, etc.
- **Flash + run**: `cargo embed --release` (uses `Embed.toml` config, opens RTT terminal)
- **Just flash**: `cargo flash --chip STM32F411VETx --release`
- **Debug**: `probe-rs gdb --chip <name>` then connect with arm-none-eabi-gdb / VSCode probe-rs-debugger
- **Logging on-device**: `defmt` + `defmt-rtt` — host-side decoded via `defmt-print` (probe-rs integrates it)
- **Async on bare metal**: `embassy-executor` + `embassy-time` + `embassy-{stm32,rp,esp32}` — proper async without an OS
- **Binary size analysis**: `cargo size --release` (needs `cargo-binutils` + `llvm-tools-preview`)

## Prerequisites
- cargo
- probe-rs CLI (installs `probe-rs`, `cargo-embed`, `cargo-flash`)
- `rustup component add llvm-tools-preview` + `cargo install cargo-binutils`
- USB debugger: ST-Link, J-Link, CMSIS-DAP, Black Magic Probe, etc.
- Linux: udev rules — see https://probe.rs/docs/getting-started/probe-setup/

## Notes
- `no_std` means no `std::*` — use `core::*` and `alloc::*` (if you opt into an allocator).
- Panic behavior: declare one — `panic-halt`, `panic-probe`, `panic-rtt-target`. The linker errors if none.
- Embassy vs RTIC: embassy = async-first, easier; RTIC = priority-based preemptive, deterministic. Pick by problem.
- For ESP32 (Xtensa or RISC-V), use the `esp-rs` toolchain (espup) — the upstream rustc only covers RISC-V ESP32-C* parts.
