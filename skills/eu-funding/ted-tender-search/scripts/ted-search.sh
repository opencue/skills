#!/usr/bin/env bash
# ted-search.sh — one-command EU tender search via the official free TED API.
#
# Usage:   ted-search.sh <BUYER_COUNTRY> [CPV_CODES] [SCOPE] [LIMIT]
#   BUYER_COUNTRY  ISO 3-letter buyer country, e.g. HUN, SVK  (required)
#   CPV_CODES      space-separated, default "72000000 48000000 73000000" (IT/sw/R&D)
#   SCOPE          ACTIVE (default, open to bid) or ALL (historical)
#   LIMIT          page size, default 50
#
# Examples:
#   ted-search.sh HUN
#   ted-search.sh SVK "72000000 48000000" ACTIVE 60
set -euo pipefail

COUNTRY="${1:?usage: ted-search.sh <BUYER_COUNTRY> [CPV] [SCOPE] [LIMIT]}"
CPV="${2:-72000000 48000000 73000000}"
SCOPE="${3:-ACTIVE}"
LIMIT="${4:-50}"

QUERY="classification-cpv IN (${CPV}) AND organisation-country-buyer IN (${COUNTRY})"

BODY=$(python3 -c 'import json,sys
print(json.dumps({"query":sys.argv[1],
  "fields":["publication-number","notice-title","buyer-name","classification-cpv","notice-type"],
  "limit":int(sys.argv[2]),"scope":sys.argv[3]}))' "$QUERY" "$LIMIT" "$SCOPE")

curl -sS -m 60 -X POST "https://api.ted.europa.eu/v3/notices/search" \
  -H "Content-Type: application/json" -d "$BODY" \
| python3 -c '
import json,sys
d=json.load(sys.stdin)
def pick(f):
    if not isinstance(f,dict): return f or ""
    for l in ("eng","hun"):
        if f.get(l): v=f[l]; return v[0] if isinstance(v,list) else v
    return next((v[0] if isinstance(v,list) else v for v in f.values()), "")
ns=sorted(d.get("notices",[]), key=lambda n:-int(n["publication-number"].split("-")[1]))
total=d.get("totalNoticeCount",0); shown=min(15,len(ns))
print("TOTAL match: %d   (showing newest %d)\n" % (total, shown))
for n in ns[:15]:
    p=n["publication-number"]
    title=pick(n.get("notice-title",""))[:70]
    buyer=pick(n.get("buyer-name",""))[:55]
    print("%s  %s" % (p, title))
    print("   %s  https://ted.europa.eu/en/notice/%s" % (buyer, p))
'
