#!/usr/bin/env bash
# Safe KDE/Plasma upgrade — always couples kf6 with plasma/kwin/kscreenlocker.
# Never run: dnf upgrade -y kf6-* alone (breaks plasmalogin greeter).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFY="${SCRIPT_DIR}/verify-plasma-versions.sh"
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: plasma-safe-upgrade [--dry-run]

Coupled DNF upgrade for KDE Frameworks + Plasma stack, then verify versions.

Options:
  --dry-run   Show what would be upgraded without applying
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "==> Dry run: packages with available updates"
  dnf check-update \
    'kf6-*' 'plasma-*' 'kdeplasma-*' \
    'kwin*' 'kscreenlocker*' 'libplasma*' 'libkworkspace6*' 2>/dev/null || true
  exit 0
fi

if ! sudo -n true 2>/dev/null; then
  echo "==> Administrative privileges required."
  sudo -v
fi

echo "==> Upgrading coupled KDE/Plasma packages..."
sudo dnf upgrade -y \
  'kf6-*' \
  'plasma-*' \
  'kdeplasma-*' \
  'kwin*' \
  'kscreenlocker*' \
  'libplasma*' \
  'libkworkspace6*'

echo ""
echo "==> Verifying Plasma coherence..."
if [[ -x "$VERIFY" ]]; then
  bash "$VERIFY"
else
  echo "WARN: verify script not found at $VERIFY" >&2
fi

running_kernel="$(uname -r)"
latest_kernel="$(ls -1 /boot/vmlinuz-* 2>/dev/null | grep -v rescue | sort -V | tail -1 | sed 's|/boot/vmlinuz-||' || true)"

echo ""
if [[ -n "$latest_kernel" && "$running_kernel" != "$latest_kernel" ]]; then
  echo "NOTE: Running kernel ($running_kernel) differs from latest ($latest_kernel)."
  echo "      Reboot recommended: sudo reboot"
else
  echo "Kernel unchanged or already on latest ($running_kernel)."
  echo "If the display misbehaves, restart plasmalogin or reboot:"
  echo "  sudo systemctl restart plasmalogin"
fi

echo ""
echo "plasma-safe-upgrade complete."
