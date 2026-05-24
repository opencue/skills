---
name: bevy
description: Use when building a game or interactive simulation in Rust with the Bevy engine — ECS-first, data-driven, hot-reloading, cross-platform (desktop + wasm).
allowed-tools: Bash(cargo:*)
---

# Bevy — Rust game engine

Entity-Component-System architecture, Rust-native, batteries-included (2D + 3D + UI + audio + input).

## When to use
- **Setup**: `bevy = "0.14"` — pin a version, Bevy churns fast and 0.x bumps are breaking
- **Hello triangle**:
  ```rust
  use bevy::prelude::*;
  fn main() {
      App::new()
          .add_plugins(DefaultPlugins)
          .add_systems(Startup, setup)
          .add_systems(Update, move_things)
          .run();
  }
  fn setup(mut cmd: Commands) { cmd.spawn(Camera2dBundle::default()); }
  fn move_things(mut q: Query<&mut Transform, With<Player>>, time: Res<Time>) { /* ... */ }
  ```
- **Spawn entities**: `commands.spawn((MeshBundle { ... }, Velocity(v), Player));` — tuples of components
- **Query data**: `Query<(&mut Transform, &Velocity), With<Player>>` — typed iteration over matching entities
- **Resources**: globally-shared state via `Res<T>` / `ResMut<T>`
- **Events**: `EventWriter<MyEvent>` / `EventReader<MyEvent>` for decoupled comms
- **States / schedules**: `add_systems(Update, my_sys.run_if(in_state(GameState::Playing)))`
- **Hot reload assets**: `bevy = { features = ["file_watcher"] }` — change PNGs without rebuilding

## Prerequisites
- cargo
- Dev deps for fast iterative builds: `[profile.dev] opt-level = 1` plus `[profile.dev.package."*"] opt-level = 3`
- On Linux: `apt install libwayland-dev libxkbcommon-dev libudev-dev libasound2-dev` (winit + audio)

## Notes
- Bevy releases break things. Read the migration guide before bumping minor versions.
- For WASM target, use `cargo run --target wasm32-unknown-unknown` with `trunk` or `wasm-server-runner` (see `rust/wasm-rust` skill).
- ECS thinking takes time — avoid global mutable state and reach for components/resources instead.
- Ecosystem crates (`bevy_egui`, `bevy_rapier`, `leafwing-input-manager`) cover UI, physics, input remapping respectively.
- Alternative engines: `macroquad` (simpler, immediate-mode), `fyrox` (scene-based, GUI editor).
