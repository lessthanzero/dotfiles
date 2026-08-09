#!/usr/bin/env bash
# Pull-only sync for allowlisted Developer repos.
set -euo pipefail

DOTFILES="${CHEZMOI_SOURCE_DIR:-${HOME}/Developer/dotfiles}"
REPOS_FILE="${DOTFILES}/skills/sync-repos/repos.yaml"
PUSH=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --push) PUSH=1; shift ;;
    -h|--help)
      echo "Usage: sync-repos.sh [--push]"
      echo "Default: git pull --ff-only on allowlisted repos."
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ "$PUSH" -eq 1 ]]; then
  echo "ERROR: --push requires explicit user confirmation in the AI session; aborting." >&2
  exit 1
fi

repos=(
  "${HOME}/Developer/dotfiles"
  "${HOME}/Developer/vault-mirror"
  "${HOME}/Developer/home-network-topology"
  "${HOME}/Developer/local-models"
  "${HOME}/Developer/personal-tools"
)

for repo in "${repos[@]}"; do
  if [[ ! -d "${repo}/.git" ]]; then
    echo "SKIP: not a git repo: $repo"
    continue
  fi
  echo "==> $repo"
  git -C "$repo" pull --ff-only || echo "WARN: pull failed for $repo" >&2
done

echo "sync-repos complete (pull-only)."
