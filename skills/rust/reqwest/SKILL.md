---
name: reqwest
description: Use when making HTTP requests from Rust — JSON APIs, file downloads, streaming. Covers reqwest (async), reqwest-middleware for retries, blocking variant, hyper for low-level.
allowed-tools: Bash(cargo:*)
---

# reqwest — Rust HTTP client

The default high-level client. Async via tokio; blocking feature flag for sync.

## When to use
- **Setup**: `reqwest = { version = "0.12", features = ["json", "rustls-tls"] }` (prefer rustls — pure-Rust, no openssl headache)
- **GET JSON**:
  ```rust
  let user: User = reqwest::get(url).await?.json().await?;
  ```
- **POST JSON + auth**:
  ```rust
  let client = reqwest::Client::new();
  let res = client.post(url).bearer_auth(token).json(&body).send().await?.error_for_status()?;
  ```
- **Streaming download**: `.bytes_stream()` returns a `Stream<Item = Result<Bytes>>`
- **Multipart upload**: `reqwest::multipart::Form::new().file("field", path).await?`
- **Reuse the client**: build once, clone everywhere (it's `Arc` internally). Don't `Client::new()` per call.
- **Retries / circuit-break**: `reqwest-middleware` + `reqwest-retry` for exponential backoff
- **Blocking**: enable `blocking` feature, use `reqwest::blocking::Client` (good for CLIs without tokio)
- **Low-level**: drop to `hyper` only when you need raw HTTP/2 frames, custom connectors, or extreme perf

## Prerequisites
- cargo
- crates: `reqwest` (+ features), usually `tokio` and `serde_json`

## Notes
- `.error_for_status()?` turns 4xx/5xx into `Err` — chain after `send()` unless you explicitly handle the body of error responses.
- For self-signed TLS in dev: `.danger_accept_invalid_certs(true)`. Never in prod.
- `reqwest::Client` holds a connection pool — don't disable it (pool size defaults are fine).
- For unit tests: `wiremock` or `mockito` to spin up a fake server; don't mock reqwest itself.
