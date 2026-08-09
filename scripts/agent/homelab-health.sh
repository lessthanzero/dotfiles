#!/usr/bin/env bash
# Read-only homelab health checks from Mac or Fedora.
set -euo pipefail

ok() { echo "OK: $*"; }
warn() { echo "WARN: $*" >&2; }
fail() { echo "FAIL: $*" >&2; }

echo "==> Tailscale"
if command -v tailscale &>/dev/null; then
  tailscale status 2>/dev/null | head -8 || warn "tailscale status failed"
else
  warn "tailscale CLI not installed"
fi

echo ""
echo "==> SSH pc (LAN)"
if ssh -o ConnectTimeout=5 -o BatchMode=yes pc 'hostname; uptime -p' 2>/dev/null; then
  ok "pc reachable via LAN"
else
  warn "pc LAN unreachable"
fi

echo ""
echo "==> SSH pc-remote (Tailscale)"
if ssh -o ConnectTimeout=5 -o BatchMode=yes pc-remote 'hostname; uptime -p' 2>/dev/null; then
  ok "pc-remote reachable"
else
  warn "pc-remote unreachable"
fi

echo ""
echo "==> Plasma / plasmalogin (via pc)"
if ssh -o ConnectTimeout=5 -o BatchMode=yes pc \
  'command -v verify-plasma-versions.sh >/dev/null && verify-plasma-versions.sh; systemctl is-active plasmalogin' 2>/dev/null; then
  ok "plasmalogin check done"
else
  warn "could not verify plasmalogin on pc"
fi

echo ""
echo "homelab-health complete."
