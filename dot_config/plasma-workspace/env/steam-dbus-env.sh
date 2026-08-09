#!/usr/bin/env bash
# Clean up stale/dead X11 socket files if present
if [ -S /tmp/.X11-unix/X0 ] && ! fuser /tmp/.X11-unix/X0 >/dev/null 2>&1; then
    rm -f /tmp/.X11-unix/X0 2>/dev/null || true
fi

# Ensure DISPLAY defaults to :0 on Wayland sessions if unset
export DISPLAY="${DISPLAY:-:0}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"

# Propagate to D-Bus and systemd --user activation environments
if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP DESKTOP_SESSION 2>/dev/null || true
fi

if command -v systemctl >/dev/null 2>&1; then
    systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP DESKTOP_SESSION 2>/dev/null || true
    systemctl --user restart flatpak-portal.service 2>/dev/null || true
fi
