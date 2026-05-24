---
name: cargo-chef
description: Use when building a Docker image of a Rust app and the dep compile step keeps invalidating cache. Splits dep compilation into a cacheable layer.
allowed-tools: Bash(cargo:*), Bash(cargo-chef:*), Bash(docker:*)
---

# cargo-chef — Docker layer caching for Rust

Without it: changing one line of your app re-downloads + recompiles all deps because Cargo.toml/lock layer changes. With it: deps live in their own cached layer.

## When to use

Multi-stage Dockerfile pattern:

```dockerfile
FROM rust:1-slim AS chef
RUN cargo install cargo-chef --locked
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json   # cached if recipe.json unchanged
COPY . .
RUN cargo build --release

FROM debian:bookworm-slim AS runtime
COPY --from=builder /app/target/release/myapp /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/myapp"]
```

## Prerequisites
- cargo-chef (used inside the build image)
- Docker / Podman with BuildKit

## Notes
- `recipe.json` is deterministic from Cargo.toml/lock — only changes when deps change, which is what makes the cache layer durable.
- Pairs well with `sccache` set via `RUSTC_WRAPPER=sccache` in the builder stage for second-level caching across machines.
- For smallest runtime images, switch the final stage to `gcr.io/distroless/cc-debian12` (static binaries can use `scratch`).
- Doesn't speed up `cargo build` locally — it's purely a Docker layer caching pattern.
