#!/usr/bin/env bash
# Brand card finisher: composite the brand logo band onto a raw Higgsfield card,
# optional OCR headline check, optional Postiz upload. Brand-parameterized.
# Usage: card.sh <raw.png> [out.png] [--brand <name>] [--check "WORDS"] [--upload]
# Composite tunables via env: BAND_H (220), LOGO_H (180), LOGO_OFF (+0+20)
set -uo pipefail
CUE_ROOT="${CUE_REPO_ROOT:-$HOME/Documents/cue}"
brand="${POSTIZ_BRAND:-volaria}"
BAND="${BAND_H:-220}"; LH="${LOGO_H:-180}"; OFF="${LOGO_OFF:-+0+20}"
raw=""; out=""; check=""; do_upload=0
while [ $# -gt 0 ]; do
  case "$1" in
    --brand)  brand="${2:-}"; shift 2;;
    --check)  check="${2:-}"; shift 2;;
    --upload) do_upload=1; shift;;
    -*)       echo "unknown option: $1"; exit 2;;
    *)        if [ -z "$raw" ]; then raw="$1"; else out="$1"; fi; shift;;
  esac
done
[ -f "$raw" ] || { echo "usage: card.sh <raw.png> [out.png] [--brand <name>] [--check \"WORDS\"] [--upload]"; exit 2; }
LOGO="$CUE_ROOT/profiles/postizz/brands/$brand/logo.png"
[ -f "$LOGO" ] || { echo "no logo for brand '$brand' at $LOGO"; exit 1; }
[ -z "$out" ] && out="${raw%.*}-card.png"

convert "$raw" -background black -gravity north -splice "0x${BAND}" \
  \( "$LOGO" -resize "x${LH}" \) -gravity north -geometry "${OFF}" -composite "$out"
echo "composited -> $out ($(identify -format '%wx%h' "$out")) [brand=$brand band=${BAND} logo=x${LH}]"

if [ -n "$check" ]; then
  if command -v tesseract >/dev/null 2>&1; then
    txt="$(tesseract "$out" - 2>/dev/null | tr '[:lower:]' '[:upper:]' | tr -d '\n')"
    miss=""
    for w in $check; do
      printf '%s' "$txt" | grep -q "$(printf '%s' "$w" | tr '[:lower:]' '[:upper:]')" || miss="$miss $w"
    done
    [ -n "$miss" ] && echo "WARN OCR: words not found ->$miss  (re-roll the card)" || echo "OK   OCR: all check words present"
  else
    echo "note: tesseract not installed; OCR headline check skipped"
  fi
fi

[ "$do_upload" = 1 ] && { echo -n "uploaded: "; postiz upload "$out" 2>&1 | grep -oE 'https?://[^"]+/uploads/[^"]+\.png' | head -1; }
