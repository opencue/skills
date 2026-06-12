#!/bin/bash
# Assemble clips into one video: sequence (or crossfade), optional intro title,
# optional background music, render to mp4. Optionally also emit a .kdenlive
# project (MLT XML) you can open in Kdenlive or re-render with render.sh.
# Usage:
#   bash assemble.sh -o out.mp4 [--xfade 12] [--title "INTRO"] [--music bg.m4a] \
#        [--project show.kdenlive] clipA.mp4 clipB.mp4 clipC.mp4
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$DIR/common.sh"
need melt; need ffprobe
OUT=out.mp4; XFADE=0; TITLE=""; MUSIC=""; PROJECT=""; CLIPS=()
while [ $# -gt 0 ]; do case "$1" in
  -o|--out) OUT="$2"; shift 2;; --xfade) XFADE="$2"; shift 2;;
  --title) TITLE="$2"; shift 2;; --music) MUSIC="$2"; shift 2;;
  --project) PROJECT="$2"; shift 2;;
  *) CLIPS+=("$1"); shift;; esac; done
[ ${#CLIPS[@]} -ge 1 ] || die "give at least one clip"
for c in "${CLIPS[@]}"; do [ -f "$c" ] || die "missing clip: $c"; done
PROFILE=$(pick_profile "${CLIPS[0]}")
echo "profile: $PROFILE | clips: ${#CLIPS[@]} | xfade: ${XFADE}f"

WORK=$(mktemp -d); trap 'rm -rf "$WORK"' EXIT
SEQ=()
if [ -n "$TITLE" ]; then
  bash "$DIR/title-card.sh" --text "$TITLE" --profile "$PROFILE" --dur 2 -o "$WORK/_title.mp4" >/dev/null
  SEQ+=("$WORK/_title.mp4")
fi
SEQ+=("${CLIPS[@]}")

# Build melt args: insert `-mix N -mixer luma` before every clip after the first.
MARGS=()
first=1
for c in "${SEQ[@]}"; do
  if [ $first -eq 1 ]; then MARGS+=("$c"); first=0
  elif [ "$XFADE" -gt 0 ] 2>/dev/null; then MARGS+=(-mix "$XFADE" -mixer luma "$c")
  else MARGS+=("$c"); fi
done

VID="$OUT"
[ -n "$MUSIC" ] && VID="$WORK/_silent.mp4"
melt -profile "$PROFILE" "${MARGS[@]}" -consumer "avformat:$VID" $VCODEC $ACODEC >/dev/null 2>&1
[ -s "$VID" ] || die "melt render failed"

if [ -n "$PROJECT" ]; then
  melt -profile "$PROFILE" "${MARGS[@]}" -consumer "xml:$PROJECT" >/dev/null 2>&1
  echo "📄 $PROJECT  (open in Kdenlive, or: bash render.sh $PROJECT -o final.mp4)"
fi

if [ -n "$MUSIC" ]; then
  need ffmpeg; [ -f "$MUSIC" ] || die "missing music: $MUSIC"
  DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$VID")
  FADE=$(awk -v d="$DUR" 'BEGIN{ printf "%.2f", (d>1? d-1 : 0) }')
  ffmpeg -nostdin -loglevel error -i "$VID" -i "$MUSIC" \
    -filter_complex "[1:a]afade=t=out:st=${FADE}:d=1[a]" \
    -map 0:v -map "[a]" -c:v copy -c:a aac -ab 192k -shortest "$OUT" -y
fi
echo "✅ $OUT  ($(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT")s, $(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0:s=x "$OUT"))"
