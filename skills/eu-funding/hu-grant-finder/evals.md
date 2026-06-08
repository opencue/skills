# Activation evals — hu-grant-finder

Run by judging each query against the `description:` only: does it fire?
Pass bar: >=90% of TRIGGER fire, <=10% of NO-TRIGGER false-fire.

## TRIGGER (must fire)

- what grants can my Hungarian company apply for?
- pályázat IT cégnek
- GINOP DIMOP support amounts
- is there funding for a new startup in Hungary?
- Hiventures venture capital eligibility
- EIC Accelerator for my AI company
- támogatás induló vállalkozásnak
- what EU funding can a Slovak company get?

## NO-TRIGGER (must NOT fire — route elsewhere)

- find EU tenders to bid on              → ted-tender-search
- search TED notices                     → ted-tender-search
- write a grant application PDF           → gstack/document-generate
- scrape palyazat.gov.hu                  → gstack/scrape
- review my code                         → none

Last run (after EIC re-added, boundary = "not tenders"):
8/8 trigger, 0/5 false-fire = 100%.
