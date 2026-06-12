#!/bin/bash
# Render a Kdenlive/MLT project file headlessly to mp4 (no GUI, no display).
# Works on .kdenlive and .mlt project files (both are MLT XML).
# Usage: bash render.sh <project.kdenlive|.mlt> [-o out.mp4]
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$DIR/common.sh"
need melt
PROJ=""; OUT=""
while [ $# -gt 0 ]; do case "$1" in
  -o|--out) OUT="$2"; shift 2;; *) PROJ="$1"; shift;; esac; done
[ -n "$PROJ" ] && [ -f "$PROJ" ] || die "Usage: bash render.sh <project.kdenlive|.mlt> [-o out.mp4]"
[ -n "$OUT" ] || OUT="${PROJ%.*}.mp4"
echo "rendering $PROJ → $OUT"
melt "$PROJ" -consumer "avformat:$OUT" $VCODEC $ACODEC >/dev/null 2>&1
[ -s "$OUT" ] || die "render failed (is this a valid MLT/Kdenlive project?)"
echo "✅ $OUT  ($(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT" 2>/dev/null)s)"
