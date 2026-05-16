---
name: awesome-rust-search
description: >-
  Use when user says "find a rust crate for X", "is there a rust library for X",
  "what's a good rust X", "search awesome-rust", or "/awesome-rust-search".
  Searches rust-unofficial/awesome-rust to recommend crates, CLIs, or apps by
  topic. NOT for crates.io version/maintenance checks — use `gh` instead. NOT
  for idiomatic Rust patterns — use std/rustdoc.
---

<!--
No upstream SKILL.md found for this workflow as of 2026-05-17.
awesome-rust is a community catalog (a README.md), not a tool with its own
skill spec. This file is local-authored. If an upstream emerges, adopt it
per the soul upstream-first rule.
-->

# Awesome Rust Search

Recommend Rust open-source projects by searching the curated
`rust-unofficial/awesome-rust` catalog. The list is a single markdown file
(~2.3k lines) organized by top-level category (`Applications`, `Libraries`,
`Development tools`, `Resources`) and sub-section (`Database`, `HTTP Client`,
`TUI`, `Cryptography`, ...). Entries are one-line bullets — perfect for
grep-and-shortlist.

## When to use

- "find a rust crate for X"
- "is there a rust library for X"
- "what's a good rust TUI / ORM / HTTP client / GUI / embedded HAL / ..."
- "search awesome-rust for X"
- "open-source rust repo that does X"
- "/awesome-rust-search <topic>"

## When NOT to use

- User names a specific crate ("is `tokio` maintained?") → point them at
  crates.io or `gh repo view`, not at the catalog.
- User asks about idiomatic Rust, std-lib usage, or language features →
  this skill is a project finder, not a tutor.
- User wants very new niches the catalog hasn't absorbed yet → say so
  and fall back to `crates.io` / `lib.rs` keyword search.

## How

### 1. Locate the catalog

Try these in order and use the first one that exists:

```sh
# Known local clones (project-vendored)
for p in \
    "$HOME/Documents/polymarket-cli/awesome-rust/README.md" \
    "$HOME/.cache/awesome-rust/README.md"; do
  [ -f "$p" ] && CATALOG="$p" && break
done

# Fallback: cache from raw GitHub
if [ -z "$CATALOG" ]; then
  mkdir -p "$HOME/.cache/awesome-rust"
  CATALOG="$HOME/.cache/awesome-rust/README.md"
  curl -fsSL \
    https://raw.githubusercontent.com/rust-unofficial/awesome-rust/main/README.md \
    -o "$CATALOG"
fi
```

If `curl` isn't available or the network is blocked, use `WebFetch` against
the same raw URL and grep its returned body.

### 2. Narrow by section first

The catalog has a table of contents at the top with anchor links like
`#http-client`, `#tui`, `#database`, `#machine-learning`. Glance at the
TOC to pick the right section before grepping the whole file — entries
appear under unambiguous headers and you'll get cleaner hits.

```sh
# List section headers to find the right one
rg -n '^(##|###|\*) ' "$CATALOG" | head -80
```

### 3. Grep with context

Entries are one bullet per line; surrounding context distinguishes
"Applications" picks from "Libraries" picks:

```sh
rg -n --no-heading -i -B2 -A1 '<keyword>' "$CATALOG"
```

For multi-intent searches, run several greps and merge — every match is
a candidate. Look at the nearest preceding `##` or `*` header to know
which section the bullet lives in.

### 4. Respond with a shortlist

Return **3–7 picks**, no more. For each pick:

- **Project name** + GitHub path (e.g. `tokio-rs/axum`)
- **One-line description** lifted from the catalog (strip the badge markdown)
- **Category section** it lives in (so the user knows the curator's intent)

Example shape:

```
Picks for "rust HTTP client" (section: Libraries → HTTP Client):

- seanmonstar/reqwest — an ergonomic HTTP Client.
- hyperium/hyper — low-level HTTP implementation.
- ducaale/xh — friendly and fast CLI for sending HTTP requests.
- 0x676e67/wreq — ergonomic HTTP client with TLS fingerprint.

(Note: `xh` is a CLI/application, not a library — pick `reqwest` or
`hyper` if you're embedding in code.)
```

Do **not** dump the whole section. The user wants a recommendation, not
a directory listing.

### 5. Disambiguate applications vs libraries

The catalog mixes:
- **Applications** = end-user binaries (`zellij`, `bat`, `bottom`)
- **Libraries** = crates you depend on (`reqwest`, `serde`, `tokio`)

Always match the recommendation to what the user is building. If they
say "I want to send HTTP requests in my code" → libraries section.
If they say "I want a CLI to test HTTP endpoints" → applications section.

### 6. Caveats to mention when relevant

- The vendored / cached catalog is a **snapshot**. If the user asks about
  maintenance status, latest version, or recent activity, check the linked
  GitHub repo via `gh repo view <owner>/<name>` instead of trusting the
  badge in the README.
- The catalog skews toward popular and battle-tested projects. Very new
  crates (under ~6 months old or low-star) may not be listed yet — fall
  back to `lib.rs` keyword search if the catalog comes up empty.

## Refreshing the cache

```sh
# Force a fresh pull
curl -fsSL \
  https://raw.githubusercontent.com/rust-unofficial/awesome-rust/main/README.md \
  -o "$HOME/.cache/awesome-rust/README.md"
```

Bump roughly quarterly; upstream merges new entries weekly but the
churn is in long-tail categories.
