#!/usr/bin/env bash
# Install JetBrains Mono Nerd Font to ~/.local/share/fonts (user, no root). Idempotent.
set -euo pipefail

FONT_DIR="${HOME}/.local/share/fonts/JetBrainsMono"
RELEASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip"
TMP_ZIP="$(mktemp /tmp/JetBrainsMono.XXXXXX.zip)"
TMP_EXTRACT="$(mktemp -d /tmp/jbm.XXXXXX)"

cleanup() {
  rm -f "$TMP_ZIP"
  rm -rf "$TMP_EXTRACT"
}
trap cleanup EXIT

font_installed() {
  fc-match "JetBrainsMono Nerd Font" 2>/dev/null | grep -q 'Nerd Font'
}

if font_installed; then
  echo "JetBrains Mono Nerd Font already installed."
  fc-match "JetBrainsMono Nerd Font"
  exit 0
fi

echo "==> Downloading JetBrainsMono Nerd Font"
curl -fsSL "$RELEASE_URL" -o "$TMP_ZIP"

echo "==> Extracting to ${FONT_DIR}"
mkdir -p "$FONT_DIR"
unzip -q "$TMP_ZIP" -d "$TMP_EXTRACT"
find "$TMP_EXTRACT" -name '*.ttf' -exec cp -t "$FONT_DIR" {} +

echo "==> Refreshing font cache"
fc-cache -fv "${HOME}/.local/share/fonts" >/dev/null

if font_installed; then
  echo "OK: JetBrains Mono Nerd Font installed."
  fc-match "JetBrainsMono Nerd Font"
else
  echo "Warning: font installed but fc-match did not find JetBrainsMono Nerd Font." >&2
  exit 1
fi
