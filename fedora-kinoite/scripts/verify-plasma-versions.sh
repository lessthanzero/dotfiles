#!/usr/bin/env bash
# Verify KDE Plasma package coherence after upgrades.
# Exit 0 if healthy; non-zero if versions or symbols are mismatched.
set -euo pipefail

FAIL=0
warn() { echo "WARN: $*" >&2; }
fail() { echo "FAIL: $*" >&2; FAIL=1; }
ok() { echo "OK: $*"; }

echo "==> Plasma package versions"
if ! command -v rpm &>/dev/null; then
  fail "rpm not found"
  exit 1
fi

kwin_ver=$(rpm -q kwin --qf '%{VERSION}' 2>/dev/null || echo "missing")
kscreen_ver=$(rpm -q kscreenlocker --qf '%{VERSION}' 2>/dev/null || echo "missing")
workspace_ver=$(rpm -q plasma-workspace --qf '%{VERSION}' 2>/dev/null || echo "missing")

if [[ "$kwin_ver" == "missing" || "$kscreen_ver" == "missing" ]]; then
  fail "kwin ($kwin_ver) or kscreenlocker ($kscreen_ver) not installed"
else
  kwin_major_minor="${kwin_ver%.*}"
  kscreen_major_minor="${kscreen_ver%.*}"
  if [[ "$kwin_major_minor" != "$kscreen_major_minor" ]]; then
    fail "Version mismatch: kwin $kwin_ver vs kscreenlocker $kscreen_ver (upgrade together)"
  else
    ok "kwin $kwin_ver and kscreenlocker $kscreen_ver aligned"
  fi
  ok "plasma-workspace ${workspace_ver}"
fi

echo ""
echo "==> libkwin ScreenLocker symbols"
if [[ -f /lib64/libkwin.so.6 ]]; then
  if nm -D /lib64/libkwin.so.6 2>/dev/null | grep -q 'U _ZN12ScreenLocker'; then
    fail "Unresolved ScreenLocker symbols in libkwin.so.6 — run plasma-safe-upgrade"
    nm -D /lib64/libkwin.so.6 2>/dev/null | grep 'U _ZN12ScreenLocker' || true
  else
    ok "No unresolved ScreenLocker symbols"
  fi
else
  warn "libkwin.so.6 not found — skipping symbol check"
fi

echo ""
echo "==> kwin_wayland binary"
if command -v kwin_wayland &>/dev/null; then
  if kwin_wayland --version &>/dev/null; then
    ok "kwin_wayland --version: $(kwin_wayland --version 2>/dev/null | head -1)"
  else
    fail "kwin_wayland --version failed (possible ABI mismatch)"
  fi
else
  warn "kwin_wayland not in PATH"
fi

echo ""
echo "==> X11 socket directory"
if [[ -d /tmp/.X11-unix ]]; then
  ok "/tmp/.X11-unix exists"
else
  fail "/tmp/.X11-unix missing — run: sudo systemd-tmpfiles --create /etc/tmpfiles.d/x11-unix.conf"
fi

echo ""
echo "==> plasmalogin"
if systemctl is-active plasmalogin &>/dev/null; then
  ok "plasmalogin is active"
elif systemctl is-active sddm &>/dev/null; then
  ok "sddm is active (legacy SDDM install)"
else
  warn "Neither plasmalogin nor sddm is active"
fi

echo ""
if [[ "$FAIL" -eq 0 ]]; then
  echo "Plasma version checks passed."
else
  echo "Plasma version checks FAILED."
  exit 1
fi
