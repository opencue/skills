#!/usr/bin/env python3
"""Pre-publish lint for Postiz brand posts (cashtag + em-dash + stat gate).

Usage: lint.py <postfile>      # tweets separated by a line containing only ===
       cat draft.txt | lint.py

Per tweet, enforces:
  - <= 1 cashtag ($TICKER)  -> X rejects 2+ as nonRetryable
  - 0 em-dashes             -> de-slop rule
  - char count (note if >280; fine on Premium)
Post-level:
  - WARN if numeric stats appear with no source link anywhere (finance EEAT gate)
Exit 1 if any tweet FAILs. Brand-agnostic.
"""
import sys, re

data = open(sys.argv[1]).read() if len(sys.argv) > 1 else sys.stdin.read()
tweets = [t.strip() for t in re.split(r'(?m)^===\s*$', data) if t.strip()]
has_source = bool(re.search(r'https?://|[Ss]ource\s*:', data))
fails = 0

for i, tw in enumerate(tweets, 1):
    cash = [c for c in re.findall(r'\$[A-Za-z]{1,6}\b', tw) if c[1:].isupper()]  # $NVDA, not $5
    em = tw.count('—')
    chars = len(tw)
    stats = re.findall(r'\b\d+(?:\.\d+)?%|\$\d[\d,.]*|\b\d{3,}\b', tw)
    flags = []
    if len(cash) > 1: flags.append(f"FAIL cashtags {cash} (max 1/tweet)")
    if em:           flags.append(f"FAIL em-dash x{em}")
    if chars > 280:  flags.append(f"note {chars} chars (>280; ok if Premium)")
    if stats and not has_source: flags.append(f"WARN uncited stats {stats[:4]} (no source link in post)")
    status = "FAIL" if any(f.startswith("FAIL") for f in flags) else ("WARN" if flags else "PASS")
    if status == "FAIL": fails += 1
    print(f"[{status}] tweet {i}: {len(cash)} cashtag, {em} em-dash, {chars} chars")
    for f in flags: print(f"         - {f}")

print(f"\n{'FAILED' if fails else 'clean'}: {len(tweets)} tweets, {fails} failing, source_present={has_source}")
sys.exit(1 if fails else 0)
