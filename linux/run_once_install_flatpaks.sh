#!/usr/bin/env bash
set -e

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

APPS=(
  md.obsidian.Obsidian
  me.kozec.syncthingtk
  org.getoutline.OutlineClient
  com.rustdesk.RustDesk
)

for app in "${APPS[@]}"; do
  if ! flatpak list --app | grep -q "$app"; then
    flatpak install --user -y flathub "$app"
  fi
done
