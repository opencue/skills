#!/usr/bin/env bash
# Postiz performance report for a brand's integration + recent posts. Brand-parameterized.
# Usage: analytics.sh [--brand <name>] [--int <integration_id>]
# WARNING: Postiz analytics LAG X by ~30x on fresh posts. Trend only; cross-check X-native.
set -uo pipefail
CUE_ROOT="${CUE_REPO_ROOT:-$HOME/Documents/cue}"
brand="${POSTIZ_BRAND:-volaria}"; INT="${POSTIZ_INT:-}"
while [ $# -gt 0 ]; do case "$1" in --brand) brand="$2"; shift 2;; --int) INT="$2"; shift 2;; *) shift;; esac; done
# fall back to the brand's accounts.yaml
[ -z "$INT" ] && INT="$(grep -oE 'cmp[a-z0-9]{20,}' "$CUE_ROOT/profiles/postizz/brands/$brand/accounts.yaml" 2>/dev/null | head -1)"
[ -n "$INT" ] || { echo "no integration id (pass --int or set POSTIZ_INT, or fill accounts.yaml for $brand)"; exit 1; }

echo "=== $brand platform analytics (Postiz - LAGS X ~30x) ==="
postiz analytics:platform "$INT" 2>&1 | python3 -c "
import sys,json
t=sys.stdin.read(); i=t.find('[')
try:
    d=json.loads(t[i:])
    for m in d:
        vals=m.get('data',[]); tot=vals[-1].get('total') if vals else '?'
        print(f'  {m.get(\"label\",\"?\"):12} {tot}')
except Exception: print('  (parse failed)', t[:120])
"
echo
echo "=== recent published posts ==="
postiz posts:list 2>/dev/null > /tmp/postiz-pl.json
python3 - <<'PY'
import json
t=open('/tmp/postiz-pl.json').read(); i=t.find('{'); d=json.loads(t[i:])
pub=[p for p in (d.get('posts') or []) if p.get('state')=='PUBLISHED']
pub.sort(key=lambda p:p.get('publishDate') or '')
for p in pub[-8:]:
    c=(p.get('content') or '').replace('\n',' ')[:38]
    print(f"  {(p.get('publishDate') or '')[:16]}  {p['id']}  {c}")
print(f"  ({len(pub)} published total)")
PY
echo
echo "GOLD STANDARD (not Postiz): the account's X-native per-post analytics, or X Premium export."
