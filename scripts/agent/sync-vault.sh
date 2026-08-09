#!/usr/bin/env bash
# Mirror iCloud vault to vault-mirror and push. No content authoring.
set -euo pipefail

VAULT="${HOME}/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vault"
MIRROR="${HOME}/Developer/vault-mirror"
MIRROR_SCRIPT="/usr/local/bin/obsidian-to-mirror.sh"

if [[ ! -d "$VAULT" ]]; then
  echo "ERROR: iCloud vault not found (Mac-only): $VAULT" >&2
  exit 1
fi

if [[ ! -x "$MIRROR_SCRIPT" ]]; then
  echo "ERROR: mirror script not found: $MIRROR_SCRIPT" >&2
  exit 1
fi

echo "==> Pre-commit incidental mirror changes (if any)"
if ! git -C "$MIRROR" diff --quiet || ! git -C "$MIRROR" diff --cached --quiet; then
  git -C "$MIRROR" status --short
  git -C "$MIRROR" add -A
  git -C "$MIRROR" commit -m "Sync incidental vault-mirror changes before mirror." || true
fi

echo "==> Mirror iCloud -> vault-mirror"
"$MIRROR_SCRIPT"

echo "==> Push vault-mirror"
git -C "$MIRROR" push -u origin HEAD

echo "sync-vault complete."
