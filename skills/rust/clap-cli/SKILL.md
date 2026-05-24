---
name: clap-cli
description: Use when building a command-line tool in Rust. Covers clap derive (subcommands, args, env), dialoguer for prompts, indicatif for progress bars/spinners.
allowed-tools: Bash(cargo:*)
---

# clap + dialoguer + indicatif — CLI building stack

`clap` is the universal arg parser. Derive macros over builder API for new code.

## When to use
- **Setup**: `clap = { version = "4", features = ["derive", "env"] }`
- **Basic args**:
  ```rust
  #[derive(clap::Parser)]
  #[command(version, about)]
  struct Args {
      #[arg(short, long, env = "MY_TOKEN")]
      token: String,
      #[arg(long, default_value_t = 10)]
      limit: usize,
      paths: Vec<PathBuf>,
  }
  fn main() {
      let args = Args::parse();
  }
  ```
- **Subcommands**: `#[derive(clap::Subcommand)]` enum + `#[command(subcommand)] cmd: Cmd` field
- **Validate**: `#[arg(value_parser = clap::value_parser!(u16).range(1..=65535))]`
- **Shell completions** (one-time gen, ship as separate file): `clap_complete::generate(Shell::Bash, &mut cmd, "myapp", &mut io::stdout())`
- **Interactive prompts** (when args are missing or for confirms): `dialoguer::{Input, Confirm, Select, Password}`
- **Progress bars**: `indicatif::{ProgressBar, MultiProgress}` — `.with_style(ProgressStyle::with_template("{spinner} {msg}").unwrap())`
- **Pretty errors**: `color-eyre` or pair `anyhow` with `tracing-subscriber` + ANSI

## Prerequisites
- cargo
- crates: `clap`, optionally `dialoguer`, `indicatif`, `color-eyre`

## Notes
- Use `env` attribute over manual `std::env::var` — clap shows env source in `--help` and respects override order.
- For subcommands, derive each in its own module; keeps the top-level enum clean.
- `Args::parse()` panics on bad input (exits with usage). For library use: `Args::try_parse()`.
- `indicatif` progress bars MUST be `drop`ped or `finish_and_clear()`ed — otherwise they leave the terminal in a weird state.
- For long-running CLIs, route logging through `tracing` and use `indicatif`-aware writer (`indicatif_log_bridge`) so logs don't break the bar.
