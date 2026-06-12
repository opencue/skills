#!/bin/bash
# Shared helpers for the kdenlive (melt/MLT) skill. Source this from each script.
# Headless: never touch a display.
export SDL_AUDIODRIVER=${SDL_AUDIODRIVER:-dummy}
export SDL_VIDEODRIVER=${SDL_VIDEODRIVER:-dummy}

VCODEC="vcodec=libx264 crf=20 preset=medium pix_fmt=yuv420p"
ACODEC="acodec=aac ab=192k"

die() { echo "Error: $*" >&2; exit 1; }

need() { command -v "$1" >/dev/null 2>&1 || die "'$1' not found. Install it (see SKILL.md prerequisites)."; }

# pick_profile <reference-media> -> echoes a melt named profile matched to the
# input's height + frame rate. Falls back to atsc_1080p_30.
pick_profile() {
  local f="$1" h fps num den val code lines name
  h=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$f" 2>/dev/null)
  fps=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of csv=p=0 "$f" 2>/dev/null)
  num=${fps%%/*}; den=${fps##*/}; [ "$den" = "$fps" ] && den=1; [ -z "$den" ] && den=1
  val=$(awk -v n="${num:-30}" -v d="${den:-1}" 'BEGIN{ if(d+0==0)d=1; printf "%.3f", n/d }')
  case "$val" in
    23.9*) code=2398;; 24.*) code=24;; 25.*) code=25;;
    29.9*) code=2997;; 30.*) code=30;; 50.*) code=50;;
    59.9*) code=5994;; 60.*) code=60;; *) code=30;;
  esac
  if [ "${h:-1080}" -le 899 ] 2>/dev/null; then lines=720; else lines=1080; fi
  name="atsc_${lines}p_${code}"
  if melt -query profiles 2>/dev/null | grep -q -- "- ${name}$"; then echo "$name"; else echo "atsc_1080p_30"; fi
}
