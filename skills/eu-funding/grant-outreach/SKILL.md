---
name: grant-outreach
description: 'Use when user says "grant outreach", "propose grants to companies by email", "grant brokerage", or asks about HU/SK B2B cold-email rules. Matches a grant to a company, drafts a compliant pitch.'
tags: [eu-funding, outreach, email, grants, compliance, hungary, slovakia]
---

# Grant outreach (HU / SK B2B)

Turn the funding-research capability into an outreach motion: find a live grant,
match it to companies that qualify, and email them a compliant proposal. This is a
brokerage / lead-gen service (not a product). Find the grants first with [[hu-grant-finder]].

## Compliance first (one complaint can outweigh a deal)

HU and SK are **opt-in** countries for marketing email (SK: Act 351/2011 §62; HU: Grt.
+ GDPR). Cold B2B email is defensible only on **GDPR legitimate interest** (Art 6(1)(f)),
and only done right:

- Email **generic company addresses** (`info@`, `obchod@`), never named persons.
- The pitch must be **genuinely relevant** (a grant the company actually qualifies for)
  and tied to their professional role. That relevance *is* the legitimate interest.
- **Identify yourself** (company, address) and give a **one-click opt-out** in every mail.
- Keep a written **LIA** (legitimate interest assessment) and an opt-out / suppression log.
- Throttle, and never re-email an opt-out.
- Verify with the **Slovak DPA** (`dataprotection.gov.sk`) or **NAIH** (HU) or a lawyer
  before scaling. This skill is not legal advice.

## Workflow

1. **Find a live grant** via [[hu-grant-finder]] (eligibility: sector, size, region, deadline).
2. **Build a target list** of companies matching the eligibility, from public registers:
   SK **ORSR** (`orsr.sk`) / **FinStat** (`finstat.sk`); HU **e-cégjegyzék** / Céginfo /
   OPTEN. Keep only generic contact addresses.
3. **Match + rank** each company to the grant: why they qualify, the amount, the deadline.
4. **Draft** a short, personal email per company (use the `email-sequence-writer` skill for
   the copy). Lead with their fit, not your service.
5. **Send compliant** through an ESP with sender-ID + opt-out + throttle + suppression list.
6. **Track** replies; price as success fee (% of grant won) or retainer.

## Email skeleton (SK / HU, compliant)

```
Subject: <Program> – <amount> for <their sector> (deadline <date>)

Dobrý deň / Tisztelt <Company>,

<Program X> is open and your company looks eligible: <1-line why: sector, size, region>.
It is <amount, %>, deadline <date>. Happy to send a 1-page fit check.

<Your name>, <Company>, <address> · <phone>
Unsubscribe: <link>   (we will not email again)
```

## Rules

- Compliance is the gate, not an afterthought: generic address + real relevance +
  sender-ID + opt-out + LIA, or do not send.
- Relevance is the legitimate-interest argument. A grant the company cannot win is spam;
  match eligibility hard first via [[hu-grant-finder]].
- Never email a named individual or a scraped personal address; never re-email an opt-out.
- This is outreach, not legal counsel. Flag the Slovak DPA / NAIH check before scaling.

## Example

User: "Let's offer Program Slovensko grants to other companies by email."

Pull the open grant + eligibility via [[hu-grant-finder]], build a target list from
ORSR / FinStat filtered to that eligibility, draft one relevant email per company to its
generic address with sender-ID + opt-out, log the LIA, and send throttled. Flag that B2B
cold email needs a legitimate-interest basis and a DPA check before scaling.
