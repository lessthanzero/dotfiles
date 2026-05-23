#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="${SCRIPT_DIR}/mint-flatpaks.txt"

read_apps() {
  grep -v '^#' "$MANIFEST" | grep -v '^[[:space:]]*$' || true
}

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

mapfile -t APPS < <(read_apps)
if [[ ${#APPS[@]} -eq 0 ]]; then
  echo "No apps listed in $MANIFEST" >&2
  exit 1
fi

for app in "${APPS[@]}"; do
  if ! flatpak list --app | grep -q "$app"; then
    flatpak install --user -y flathub "$app"
  fi
done
