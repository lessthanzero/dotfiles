#!/usr/bin/env bash
# Ensure DISPLAY defaults to :0 on Wayland sessions if unset
export DISPLAY="${DISPLAY:-:0}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"

# Propagate to D-Bus and systemd --user activation environments
if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP DESKTOP_SESSION 2>/dev/null || true
fi

if command -v systemctl >/dev/null 2>&1; then
    systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP DESKTOP_SESSION 2>/dev/null || true
    # Force flatpak-portal to pick up updated systemd environment if already active
    systemctl --user restart flatpak-portal.service 2>/dev/null || true
fi
