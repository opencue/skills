---
name: ted-tender-search
description: 'Use when user says "find EU tenders", "TED search", "public procurement", "közbeszerzés", or wants EU procurement notices by CPV, country, or keyword. Queries the free official TED API (no key).'
tags: [eu-funding, tenders, procurement, ted, hungary]
---

# TED tender search

Search live EU public-procurement notices through the **official TED API** (Tenders
Electronic Daily). Free, no API key, no scraper. This is the canonical source, 
Apify/Firecrawl and most "TED MCPs" just resell this same data.

- **Endpoint:** `POST https://api.ted.europa.eu/v3/notices/search`
- **Auth:** none
- **Notice page:** `https://ted.europa.eu/en/notice/<publication-number>` (e.g. `568232-2025`)

## Run a search (one command)

`scripts/ted-search.sh` builds the query, calls the API, and prints the newest 15
notices ranked, with buyer + notice URL. Args: buyer country, CPV codes, scope, limit.

```bash
scripts/ted-search.sh HUN "72000000 48000000 73000000" ACTIVE 50
```

It prints `TOTAL match: <n>` (the full count, not just the page). For custom filters
(`place-of-performance`, `FT ~ (...)`) build the body by hand using the fields below;
the request is `POST https://api.ted.europa.eu/v3/notices/search` with JSON
`{query, fields, limit, scope}`, `scope` = `ACTIVE` (open) or `ALL` (historical).

## Query language (verified fields)

| Filter | Field | Example |
|---|---|---|
| CPV code | `classification-cpv IN (...)` | `classification-cpv IN (72000000 48000000)` |
| Buyer's country | `organisation-country-buyer IN (...)` | `organisation-country-buyer IN (HUN)` |
| Where work is performed | `place-of-performance IN (...)` | `place-of-performance IN (HUN SVK)` |
| Full text (title/summary) | `FT ~ ("..." "...")` | `FT ~ ("artificial intelligence" "mesterséges intelligencia")` |

- Combine with `AND` / `OR`. Country codes are **ISO 3-letter** (`HUN`, `SVK`, `AUT`).
- `organisation-country-buyer` (who buys) is usually a sharper filter than
  `place-of-performance` (where work happens), the latter also catches EU-institution
  contracts that merely touch the country.
- `FT ~ (...)` searches a narrow title/summary field, expect few hits; it is for
  pinpointing, not broad discovery.

## CPV codes for IT / AI / software work

| CPV | Domain |
|---|---|
| `72000000` | IT services: consulting, software development, internet, support |
| `48000000` | Software packages and information systems |
| `73000000` | R&D services |

## Ranking

The API has no relevance sort, so `ted-search.sh` ranks by recency (the publication
number embeds the year, `NNNNNN-YYYY`) and picks the `eng` then `hun` value from the
multilingual title/buyer objects (`{"eng":[...], "hun":[...]}`). Edit the script's
final `python3` filter to sort by a different field.

## Rules

- Always hit the official API first; do not reach for a paid scraper or a TED MCP for
  search, they wrap this same free endpoint.
- Use `scope: "ACTIVE"` for biddable tenders; `"ALL"` only to size history.
- Report `totalNoticeCount`, not just the page you pulled, so the user sees the real universe.
- Every tender you surface carries its publication number + notice URL. No number, not in the list.
- A new company rarely wins a tender directly (references/turnover needed), flag the
  subcontractor route. For *grants/funding* (not procurement), use [[hu-grant-finder]].

## Example

User: "Find open IT tenders from Hungarian buyers."

Query `classification-cpv IN (72000000 48000000 73000000) AND organisation-country-buyer IN (HUN)`
with `scope: "ACTIVE"`, report `totalNoticeCount`, then list the newest 15 with
publication number + notice URL. Add `place-of-performance IN (HUN SVK)` to widen to
Slovakia, or `FT ~ ("artificial intelligence" "mesterséges intelligencia")` to pinpoint
AI notices.
