#!/bin/bash
# Render a standalone title card: solid background + centered text (Montserrat).
# Usage: bash title-card.sh --text "BIG TITLE" [--subtitle "small"] [--bg "#1a1a2e"]
#        [--fg "#ffffff"] [--dur 2.5] [--size 96] [--profile atsc_1080p_30] -o card.mp4
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$DIR/common.sh"
need melt
TEXT=""; SUB=""; BG="#101018"; FG="#ffffff"; DUR=2.5; SIZE=96; PROFILE=atsc_1080p_30; OUT=card.mp4; FONT=Montserrat
while [ $# -gt 0 ]; do case "$1" in
  --text) TEXT="$2"; shift 2;; --subtitle) SUB="$2"; shift 2;;
  --bg) BG="$2"; shift 2;; --fg) FG="$2"; shift 2;; --dur) DUR="$2"; shift 2;;
  --size) SIZE="$2"; shift 2;; --font) FONT="$2"; shift 2;;
  --profile) PROFILE="$2"; shift 2;; -o|--out) OUT="$2"; shift 2;;
  *) die "unknown arg: $1";; esac; done
[ -n "$TEXT" ] || die "--text is required"
FPS=$(melt -query profile=$PROFILE 2>/dev/null | awk -F= '/frame_rate_num/{n=$2} /frame_rate_den/{d=$2} END{ if(d=="")d=1; printf "%d", (n/d)+0.5 }'); [ "${FPS:-0}" -gt 0 ] || FPS=30
FRAMES=$(awk -v d="$DUR" -v f="$FPS" 'BEGIN{ printf "%d", (d*f)-1 }')
# melt color hex wants 0xRRGGBBAA; convert "#RRGGBB" -> 0xRRGGBBff
hex(){ printf '0x%sff' "$(echo "$1" | tr -d '#')"; }
set -- melt -profile "$PROFILE" "color:$(hex "$BG")" out="$FRAMES" \
  -filter "dynamictext:$TEXT" family="$FONT" size="$SIZE" weight=700 fgcolour="$(hex "$FG")" valign=middle halign=center
[ -n "$SUB" ] && set -- "$@" -filter "dynamictext:$SUB" family="$FONT" size=$((SIZE/3)) fgcolour="$(hex "$FG")" valign=bottom halign=center olcolour=0x00000000
"$@" -consumer "avformat:$OUT" $VCODEC $ACODEC >/dev/null 2>&1
[ -s "$OUT" ] || die "render produced no output"
echo "✅ $OUT  (${DUR}s @ ${PROFILE})"
