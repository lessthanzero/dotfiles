#!/usr/bin/env bash
# Tile active window to right half (see xfce-tile-left.sh).
set -euo pipefail

geo="$(xrandr --current 2>/dev/null | awk '/\*\+/{print $1; exit}')"
[[ -n "$geo" ]] || exit 0
width="${geo%%x*}"
height="${geo##*x}"
half=$((width / 2))
wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz 2>/dev/null || true
wmctrl -r :ACTIVE: -e "0,${half},0,${half},${height}"
