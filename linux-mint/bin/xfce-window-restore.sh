#!/usr/bin/env bash
# Restore active window from maximized/tiled to default size (Super+Down).
set -euo pipefail

wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
