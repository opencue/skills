#!/bin/bash
# Reframe a video to a target social aspect with a blurred-fill background
# (no stretching, no hard crop of the subject). Uses ffmpeg.
# Usage: bash reframe.sh <in.mp4> --aspect 9:16|1:1|16:9 [--height 1920] -o out.mp4
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$DIR/common.sh"
need ffmpeg
IN=""; ASPECT=9:16; H=""; OUT=""
while [ $# -gt 0 ]; do case "$1" in
  --aspect) ASPECT="$2"; shift 2;; --height) H="$2"; shift 2;;
  -o|--out) OUT="$2"; shift 2;; *) IN="$1"; shift;; esac; done
[ -n "$IN" ] && [ -f "$IN" ] || die "Usage: bash reframe.sh <in.mp4> --aspect 9:16 -o out.mp4"
case "$ASPECT" in
  9:16) W=1080; DH=1920;; 1:1) W=1080; DH=1080;; 16:9) W=1920; DH=1080;;
  *) die "aspect must be 9:16, 1:1, or 16:9";; esac
[ -n "$H" ] && { DH="$H"; W=$(awk -v dh="$DH" -v a="$ASPECT" 'BEGIN{split(a,p,":"); printf "%d", dh*p[1]/p[2]}'); }
[ -n "$OUT" ] || OUT="${IN%.*}_${ASPECT/:/x}.mp4"
ffmpeg -nostdin -loglevel error -i "$IN" -filter_complex \
 "[0:v]split[a][b];[a]scale=${W}:${DH}:force_original_aspect_ratio=increase,crop=${W}:${DH},boxblur=22[bg];[b]scale=${W}:-2:force_original_aspect_ratio=decrease[fg];[bg][fg]overlay=(W-w)/2:(H-h)/2" \
 -c:v libx264 -crf 20 -preset medium -pix_fmt yuv420p -c:a copy "$OUT" -y
[ -s "$OUT" ] || die "reframe failed"
echo "✅ $OUT  ($(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0:s=x "$OUT"))"
