#!/bin/bash
# chezmoi:script
# Ensure Midnight Commander uses the Tokyo Night skin from dot_local/share/mc/skins/.
set -euo pipefail

ini="${HOME}/.config/mc/ini"
mkdir -p "$(dirname "$ini")"

if [[ ! -f "$ini" ]]; then
  printf '[Midnight-Commander]\nskin=tokyonight\n' >"$ini"
  exit 0
fi

if grep -q '^skin=' "$ini"; then
  sed -i 's/^skin=.*/skin=tokyonight/' "$ini"
elif grep -q '^\[Midnight-Commander\]' "$ini"; then
  sed -i '/^\[Midnight-Commander\]/a skin=tokyonight' "$ini"
else
  printf '[Midnight-Commander]\nskin=tokyonight\n\n' | cat - "$ini" >"${ini}.tmp"
  mv "${ini}.tmp" "$ini"
fi
