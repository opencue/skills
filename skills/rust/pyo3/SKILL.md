---
name: pyo3
description: Use when exposing Rust code to Python — write a CPython extension module in Rust, ship as a wheel via maturin.
allowed-tools: Bash(cargo:*), Bash(maturin:*), Bash(python:*), Bash(pip:*)
---

# PyO3 + maturin — Rust → Python

Used by `cryptography`, `polars`, `tokenizers`, `pydantic-core`. The path for "Rust speed in Python".

## When to use
- **Init**: `maturin new --bindings pyo3 my_ext`
- **Cargo.toml**:
  ```toml
  [lib]
  crate-type = ["cdylib"]
  [dependencies]
  pyo3 = { version = "0.22", features = ["extension-module"] }
  ```
- **Expose a fn**:
  ```rust
  use pyo3::prelude::*;
  #[pyfunction] fn sum(a: i64, b: i64) -> i64 { a + b }
  #[pymodule]   fn my_ext(m: &Bound<'_, PyModule>) -> PyResult<()> { m.add_function(wrap_pyfunction!(sum, m)?)?; Ok(()) }
  ```
- **Develop loop**: `maturin develop --release` installs into the active venv; `import my_ext; my_ext.sum(2,3)`
- **Build wheel**: `maturin build --release` → `target/wheels/*.whl`
- **Publish to PyPI**: `maturin publish` (or `maturin upload`)
- **Async** (call async Rust from Python): `pyo3-asyncio` integrates tokio with Python's asyncio

## Prerequisites
- cargo
- Python 3.8+ in a venv (recommended) or system Python
- maturin (`pipx install maturin`)

## Notes
- Use a venv — `maturin develop` installs INTO whatever Python is active. Wrong env = wrong wheel installed.
- For multi-Python-version wheels: `maturin build --release --interpreter python3.10 python3.11 python3.12` or use `cibuildwheel` in CI.
- GIL handling: `Python::with_gil(|py| ...)` for any PyObject work. Release the GIL during pure Rust compute with `py.allow_threads(|| ...)`.
- Distribute as `abi3` (stable ABI) via `pyo3 = { features = ["abi3-py38"] }` so ONE wheel covers Python 3.8+.
