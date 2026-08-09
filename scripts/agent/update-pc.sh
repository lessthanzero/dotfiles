#!/usr/bin/env bash
# Host-aware Fedora/KDE safe upgrade. See vault ops/fedora-kde-updates.md
set -euo pipefail

run_remote() {
  local host="$1"
  shift
  ssh -o ConnectTimeout=10 "$host" "$@"
}

if [[ "$(hostname -s 2>/dev/null)" == "fedora" ]] || [[ -f /etc/fedora-release ]]; then
  if command -v plasma-safe-upgrade &>/dev/null; then
    exec plasma-safe-upgrade "$@"
  fi
  echo "ERROR: plasma-safe-upgrade not installed. Run fedora-kinoite/bootstrap.sh" >&2
  exit 1
fi

if run_remote pc "echo ok" &>/dev/null; then
  exec ssh pc plasma-safe-upgrade "$@"
fi

if run_remote pc-remote "echo ok" &>/dev/null; then
  exec ssh pc-remote plasma-safe-upgrade "$@"
fi

echo "ERROR: cannot reach pc (LAN) or pc-remote (Tailscale)" >&2
exit 1
