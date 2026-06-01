#!/usr/bin/env bash
# Tile active window to left half (XFCE workaround: xfwm4 Super+arrow fails when
# Super alone is grabbed by libxfce4ui; application shortcuts handle the combo).
set -euo pipefail

geo="$(xrandr --current 2>/dev/null | awk '/\*\+/{print $1; exit}')"
[[ -n "$geo" ]] || exit 0
width="${geo%%x*}"
height="${geo##*x}"
half=$((width / 2))
wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz 2>/dev/null || true
wmctrl -r :ACTIVE: -e "0,0,0,${half},${height}"
