#!/bin/bash
# Probe one or more media files: duration, resolution, fps, codecs, audio.
# Usage: bash inspect.sh <file> [file...]
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$DIR/common.sh"
need ffprobe
[ $# -ge 1 ] || die "Usage: bash inspect.sh <file> [file...]"
for f in "$@"; do
  [ -f "$f" ] || { echo "missing: $f"; continue; }
  echo "── $f"
  ffprobe -v error -select_streams v:0 \
    -show_entries stream=width,height,r_frame_rate,codec_name,bit_rate \
    -show_entries format=duration,size,format_name \
    -of default=noprint_wrappers=1 "$f"
  a=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name,channels,sample_rate -of default=noprint_wrappers=1 "$f" 2>/dev/null)
  [ -n "$a" ] && echo "$a" | sed 's/^/audio.&/'
  echo "  → melt profile match: $(pick_profile "$f")"
  echo
done
