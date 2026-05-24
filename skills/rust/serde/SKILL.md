---
name: serde
description: Use when (de)serializing Rust data to JSON, TOML, YAML, MessagePack, etc. Covers derive macros, attributes, custom (de)serializers, common lifetime/Cow gotchas.
allowed-tools: Bash(cargo:*)
---

# serde — universal serialization

The Rust ecosystem's standard. Every non-trivial project pulls it in.

## When to use
- **JSON**: `serde` + `serde_json`. Derive: `#[derive(Serialize, Deserialize)]`
- **TOML/YAML**: swap `serde_json` for `toml` / `serde_yaml` (or `serde_yml`)
- **Binary**: `bincode`, `rmp-serde` (MessagePack), `postcard` (no_std)
- **Field rename**: `#[serde(rename = "fooBar")]` · case style: `#[serde(rename_all = "camelCase")]`
- **Optional field**: `Option<T>` + `#[serde(skip_serializing_if = "Option::is_none")]`
- **Default on missing**: `#[serde(default)]` or `#[serde(default = "my_fn")]`
- **Enum repr**: `#[serde(tag = "type")]` (internally tagged), `#[serde(untagged)]` (try each variant)
- **Flatten nested**: `#[serde(flatten)]` for `{ "inner": {...} }` → flat shape
- **Custom (de)serializer per field**: `#[serde(deserialize_with = "path")]`

## Prerequisites
- cargo
- crates: `serde = { version = "1", features = ["derive"] }`, plus a format crate

## Notes
- For zero-copy deserialization, use `&'a str` / `Cow<'a, str>` and add `#[serde(borrow)]` — saves allocs when the source bytes outlive the struct.
- `#[serde(untagged)]` is convenient but slow (tries each variant); prefer `tag` when possible.
- `serde_json::Value` is the escape hatch for unknown shapes; downcast to concrete types ASAP for perf and clarity.
- For numbers from JSON: deserialize into `f64`/`i64` and convert — JSON has no native int/float distinction.
