---
name: axum-api
description: Use when building an HTTP API or web service in Rust. Covers axum (recommended), with notes on actix-web and rocket. Extractors, layers, error types, OpenAPI.
allowed-tools: Bash(cargo:*)
---

# axum — the standard Rust web framework

Built on `hyper` + `tower`. Tokio-native. Used by Discord, Cloudflare, etc.

## When to use
- **Minimum router**:
  ```rust
  let app = Router::new()
      .route("/users/:id", get(get_user))
      .route("/users", post(create_user))
      .with_state(app_state);
  let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await?;
  axum::serve(listener, app).await?;
  ```
- **Extractors** (extract from request): `Path<T>`, `Query<T>`, `Json<T>`, `State<S>`, `Extension<T>`, custom `FromRequestParts`
- **Responses**: return any `IntoResponse` — `Json<T>`, `(StatusCode, body)`, custom error types
- **Error type**: define one app-wide `AppError`; impl `IntoResponse` mapping variants to status codes
- **Middleware (layers)**: `.layer(TraceLayer::new_for_http())` for logging, `.layer(CorsLayer::permissive())`, custom via `tower::Service`
- **Shared state**: `Router::with_state(state)` then `State(s): State<AppState>` extractor
- **WebSocket**: `WebSocketUpgrade` extractor
- **OpenAPI**: `utoipa` + `utoipa-swagger-ui` to auto-gen docs from `#[derive(ToSchema)]` + `#[utoipa::path]`
- **Alternatives**: `actix-web` (older, fast, actor-flavored), `rocket` (macro-heavy, less async-idiomatic)

## Prerequisites
- cargo
- crates: `axum`, `tokio = { features = ["full"] }`, `tower-http`, `serde`

## Notes
- Always wrap with `TraceLayer` + a tracing subscriber — request logs cost ~zero and save days of debugging.
- For >50 routes, split into modules each returning a `Router<AppState>` and `.merge()` them in `main`.
- Don't manually parse `Authorization` headers in every handler — write a custom extractor once.
- Health/readiness endpoints belong on a separate `Router` mounted unconditionally (no auth middleware).
