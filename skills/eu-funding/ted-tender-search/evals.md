# Activation evals — ted-tender-search

Run by judging each query against the `description:` only: does it fire?
Pass bar: >=90% of TRIGGER fire, <=10% of NO-TRIGGER false-fire.

## TRIGGER (must fire)

- find EU tenders for IT companies
- search TED for Hungarian procurement
- közbeszerzés keresés szoftverre
- what public procurement notices are open in Slovakia?
- find tenders by CPV code 72000000
- are there open EU contracts my company can bid on?
- TED search for AI tenders
- list active procurement notices from Hungarian buyers

## NO-TRIGGER (must NOT fire — route elsewhere)

- find grants for my startup            → hu-grant-finder
- what GINOP can I apply for?           → hu-grant-finder
- find me a venture capital investor    → hu-grant-finder
- write me a bid proposal               → content/article-writer
- scrape this website                   → gstack/scrape
- how do I register a Kft?              → none

Last run: 8/8 trigger, 0/6 false-fire = 100%.
