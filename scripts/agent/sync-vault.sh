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

# git diff reports only tracked files, so a brand-new note is invisible to it. Use
# status --porcelain, which lists untracked paths too.
dirty() { [[ -n "$(git -C "$MIRROR" status --porcelain)" ]]; }

commit_all() {
  git -C "$MIRROR" status --short
  git -C "$MIRROR" add -A
  git -C "$MIRROR" commit -m "$1"
}

echo "==> Pre-commit incidental mirror changes (if any)"
if dirty; then
  commit_all "Sync incidental vault-mirror changes before mirror." || true
fi

echo "==> Mirror iCloud -> vault-mirror"
"$MIRROR_SCRIPT"

# The mirror step is what brings authored notes across, so this is the commit that
# actually captures them. Without it, rsync output sat in the tree uncommitted and
# the push below silently carried nothing.
echo "==> Commit mirrored content"
if dirty; then
  commit_all "Sync vault content from iCloud."
else
  echo "  nothing to commit"
fi

# Another machine may have pushed since the last sync; fast-forward first so the push
# is not rejected. --ff-only refuses to invent a merge, so this stays safe unattended.
echo "==> Fast-forward from origin"
BRANCH="$(git -C "$MIRROR" rev-parse --abbrev-ref HEAD)"
git -C "$MIRROR" fetch origin "$BRANCH" || true
if git -C "$MIRROR" rev-parse --verify --quiet "origin/${BRANCH}" >/dev/null; then
  if ! git -C "$MIRROR" merge --ff-only "origin/${BRANCH}"; then
    echo "ERROR: ${MIRROR} has diverged from origin/${BRANCH}; resolve by hand." >&2
    exit 1
  fi
fi

echo "==> Push vault-mirror"
git -C "$MIRROR" push -u origin HEAD

echo "sync-vault complete."
