#!/usr/bin/env bash
# Maximize active window (Super+Up; see xfce-tile-left.sh for Mint/X11 workaround).
set -euo pipefail

wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz
