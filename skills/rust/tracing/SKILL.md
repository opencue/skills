---
name: tracing
description: Use when adding logging, structured logs, spans, or live runtime introspection to a Rust app. Covers tracing, tracing-subscriber, tokio-console, OpenTelemetry.
allowed-tools: Bash(cargo:*), Bash(tokio-console:*)
---

# tracing — modern Rust observability

Replaces `log` for new code. Structured + async-aware (spans cross await points).

## When to use
- **Setup**: `tracing` + `tracing-subscriber`. Init at start of `main`:
  ```rust
  tracing_subscriber::fmt()
      .with_env_filter(tracing_subscriber::EnvFilter::from_default_env())
      .init();
  ```
- **Emit**: `tracing::{trace, debug, info, warn, error}!("msg {field}", field = value)`
- **Structured fields**: `info!(user_id = %uuid, count = 5, "request done");`
- **Spans**: `let _s = tracing::info_span!("op", id = %req_id).entered();` (sync) or `.instrument(span)` on a future (async)
- **Auto-instrument fns**: `#[tracing::instrument]` macro
- **JSON logs** (for prod): `tracing_subscriber::fmt().json().init()`
- **Filter via env**: `RUST_LOG=info,my_crate=debug,hyper=warn`
- **Runtime introspection**: enable `console-subscriber` + `RUSTFLAGS="--cfg tokio_unstable"`, then run `tokio-console`
- **OpenTelemetry export**: `tracing-opentelemetry` + `opentelemetry-otlp` for OTLP/Jaeger/Tempo

## Prerequisites
- cargo
- crates: `tracing`, `tracing-subscriber`
- For runtime view: `tokio-console` CLI + `console-subscriber` crate

## Notes
- `%value` = use Display; `?value` = use Debug; bare `value` = use the trait it implements.
- Spans propagate across `.await` only if you `.instrument(span)` the future explicitly — otherwise context is lost at the suspend point.
- Don't `#[instrument]` hot-path fns — span overhead adds up. Reserve for request-level boundaries.
- For libraries: emit tracing events, don't init a subscriber. Subscriber init is the binary's job.
