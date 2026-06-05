---
name: hu-grant-finder
description: 'Use when user says "find grants", "pályázat", "támogatás", "GINOP", "DIMOP", "Hiventures", "EIC", or what funding a HU/SK company can apply for. Maps grants, loans, VC, not tenders.'
tags: [eu-funding, grants, palyazat, ginop, hungary, venture-capital]
---

# Hungarian / EU grant & funding finder

Map the funding a company can actually get, by channel and by stage. Built for
agentic-AI / IT companies in Hungary (extendable to SK). **Grants are not tenders**, 
for public procurement (selling to the state) use [[ted-tender-search]].

## First: pick the right channel (they get confused constantly)

| Channel | What it is | You... | Repay? |
|---|---|---|---|
| **Közbeszerzés / tender** | TED procurement | *sell* services to the state | no (you earn) |
| **Támogatás / grant** | GINOP/DIMOP, EU grants | get non-repayable money for a project | no |
| **Kedvezményes hitel** | MFB / GINOP loan programs | borrow cheap (often 0%) | **yes** |
| **Kockázati tőke / VC** | Hiventures, EIC, EU funds | take equity investment | no, but give **equity** |

## The funding ladder (Hungarian micro/IT company)

```
 0 lezárt év          1+ lezárt üzleti év            deep-tech / scalable product
 ──────────           ──────────────────             ───────────────────────────
 Vállalkozóvá válás   KKV grants & 0% loans          Hiventures (GINOP 2.5.1, ≤€300k)
 (NFSZ, ~4,9M Ft,     (DIMOP/GINOP — when a round    EIC Accelerator (≤€2,5M + equity)
  if jobseeker)        is open; check forrás left)   → needs TRL6 product + company
 + "saját honlap"      EV closed year COUNTS;         → "only-software" firms may be
   voucher (0,4–2M)    don't found a fresh Kft and     excluded from VC — verify
                       reset the closed-year clock
```

## Canonical sources (check live, frames run "until funds run out")

- **palyazat.gov.hu**, official Széchenyi Terv Plusz portal; the *active list* is the
  source of truth for open/closed. JS-rendered: status reliable, deep params need the PDF.
- **nkfih.gov.hu**, innovation & VC calls (GINOP 2.x). Often slow/times out, be patient.
- **mfb.hu**, the loan programs (GINOP 1.4.x KKV Technológia Hitel).
- **hiventures.hu**, the early-stage VC fund manager (runs GINOP 2.5.1, ≤€300k).
- **eic.ec.europa.eu**, EIC Accelerator (deep-tech, ≤€2,5M grant + equity).
- **ec.europa.eu/info/funding-tenders**, EU Funding & Tenders Portal.
- Aggregators (palyazatmenedzser, palyaz.hu, eumanagement) are useful for the *active
  list* but are **paywalled / conflicting** on detail and status, confirm against official.

## Slovakia (SK) sources

The same channels, ladder, and gotchas apply; swap the Hungarian portals for the SK ones:

| Channel | HU | SK equivalent |
|---|---|---|
| EU-funds portal (source of truth) | palyazat.gov.hu | **ITMS21+** (`portal.itms21.sk`, `itms2014.sk`) |
| Operational programme | Széchenyi Terv Plusz | **Program Slovensko 2021-2027** (`eurofondy.gov.sk`) |
| Cheap loan / digital | MFB, GINOP 1.4.x | **Plán obnovy / VAIA** via SIH (digital, rate cut + up to 30% loan forgiveness) |
| Early-stage VC | Hiventures | **Venture to Future Fund** (`vff.sk`) via Slovak Investment Holding (EIB + MoF, IT focus) |
| Micro / SME | KKV grants | **Slovak Business Agency (SBA)** microloans €2,500-50,000; **National Holding Fund** €20k-1.5M (IT) |
| Innovation / R&D advisory | NKFIH | **SIEA** regional advisory; **APVV / VAIA** R&D grants |

EU-level (EIC, Digital Europe, Horizon) is shared across both countries. Confirm live
status on the SK portal, the same "funds run out" caveat applies.

## Hard-won gotchas (verified this domain, they bite every time)

- **Closed-year wall.** Most KKV grants/loans (DIMOP 1.2.6, GINOP 1.4.3) require ≥1
  full closed business year + ≥1 employee. A brand-new company cannot apply day one.
- **EV counts.** An egyéni vállalkozó's closed tax year *is* a closed business year, and
  EV is usually an eligible form. Don't throw that history away by founding a fresh Kft.
- **Region split.** For DIMOP/GINOP the line is Budapest (`/C`) vs. every other county
  (`/B`, "less developed"), wealthy counties like Győr-Moson-Sopron are in the *favoured*
  `/B`, but ~65% of some loan frames is ring-fenced for the 4 most-disadvantaged regions.
- **Timing kills.** Frames close on *forráskimerülés* (funds exhausted), often before the
  stated deadline. The spring-2026 round closed DIMOP 1.2.6/B, GINOP 1.2.4, 2.1.3, 2.1.4.
  Always re-check the active list the same day.
- **VC ≠ free.** Hiventures/EIC take equity and need a TRL6 working product + a company.
- **"Only software" exclusion.** GINOP 2.5.1 (Hiventures) excludes firms developing *only*
  immaterial assets (software). A pure SaaS/agent-wrapper play may not qualify, needs a
  data/hardware/vertical asset beyond code. Verify the exact clause in the call PDF.
- **Deep-tech ≠ SaaS for EIC.** An LLM-wrapper is SaaS, not deep tech; EIC wants
  breakthrough + technological risk. Hungary is a "widening" country → EIC **Pre-Accelerator**
  is the realistic stepping stone before the full Accelerator.

## Research procedure

1. **Classify the ask**, tender / grant / loan / VC (table above). Wrong channel wastes hours.
2. **Place on the ladder**, how many closed business years? That gates everything.
3. **Pull the active list**, palyazat.gov.hu (grants/loans) + hiventures.hu / eic (VC).
   Filter to the company's region and form.
4. **Confirm status + eligibility** from the official call PDF (not aggregators): open?
   closed-year requirement? region? amount? intensity? exclusions?
5. **Rank by fit**, run `/roi-estimator` when listing 3+ options.
6. **Tag confidence**, amounts/deadlines move weekly; mark unverified figures and name the
   one thing to confirm by phone (NKFIH / kormányhivatal) before the user acts.

## Rules

- Never quote a grant amount, deadline, or eligibility from memory, it is stale. Fetch live
  and tag confidence; a "verify at palyazat.gov.hu" beats a confident wrong number.
- State the channel explicitly every time (grant vs loan vs equity), the user conflates them.
- Match the portal to the company's country: HU goes to palyazat.gov.hu, SK to ITMS21+ /
  eurofondy.gov.sk. Don't quote a Hungarian program to a Slovak company or vice versa.
- Surface the closed-year and region gates *before* detailing amounts; they disqualify fastest.
- For procurement/tenders, hand off to [[ted-tender-search]]. For deep research sweeps, [[defuddle]].

## Example

User: "I just started a Hungarian IT company. What grants can I apply for?"

Classify (grant, not tender), place on the ladder: 0 closed years means the big KKV
grants (DIMOP, GINOP) are gated out, so day-one is vállalkozóvá válás (if a jobseeker
founder) plus the saját-honlap voucher; the real money opens after one closed business
year. If the company is a scalable AI *product* at TRL6, route to Hiventures (GINOP
2.5.1, equity), watching the "only software" exclusion. Pull the live active list from
palyazat.gov.hu, confirm eligibility in the call PDF, and tag every amount's confidence.
