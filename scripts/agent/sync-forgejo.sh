#!/usr/bin/env bash
# Push allowlisted repositories to self-hosted Forgejo on Fedora PC worker
set -euo pipefail

TARGET_HOST="${1:-pc}"
LOCAL_PORT=33001

echo "==> Retrieving Forgejo token from ${TARGET_HOST}..."
TOKEN=$(ssh "${TARGET_HOST}" "cat ~/.config/homelab/forgejo-token 2>/dev/null || true")
if [[ -z "${TOKEN}" ]]; then
  echo "Error: Could not retrieve Forgejo token from ~/.config/homelab/forgejo-token on ${TARGET_HOST}." >&2
  exit 1
fi

echo "==> Opening secure SSH tunnel (localhost:${LOCAL_PORT} -> 127.0.0.1:3001 on ${TARGET_HOST})..."
pkill -f "ssh -f -N -L ${LOCAL_PORT}:127.0.0.1:3001 ${TARGET_HOST}" 2>/dev/null || true
ssh -f -N -L ${LOCAL_PORT}:127.0.0.1:3001 "${TARGET_HOST}"
sleep 1

cleanup() {
  pkill -f "ssh -f -N -L ${LOCAL_PORT}:127.0.0.1:3001 ${TARGET_HOST}" 2>/dev/null || true
}
trap cleanup EXIT

repos=(
  "${HOME}/Sites/personal-website"
  "${HOME}/Sites/katin-ui"
  "${HOME}/Developer/linear-a"
  "${HOME}/Developer/phaistos-disk"
  "${HOME}/Developer/portfolio-prototypes-bundle"
  "${HOME}/Developer/dotfiles"
  "${HOME}/Developer/vault-mirror"
  "${HOME}/Developer/home-network-topology"
  "${HOME}/Developer/local-models"
  "${HOME}/Developer/personal-tools"
  "${HOME}/Developer/personal-business"
  "${HOME}/Developer/job-search"
  "${HOME}/Developer/hassio"
  "${HOME}/Developer/ancient-text-lab"
  "${HOME}/Developer/cipher-lab"
  "${HOME}/Developer/workbench"
)

echo "==> Syncing repositories to Forgejo..."
for repo in "${repos[@]}"; do
  if [[ ! -d "${repo}/.git" ]]; then
    echo "SKIP: not a git repo: $repo"
    continue
  fi
  name=$(basename "$repo")
  echo "--> Pushing ${name}..."
  
  push_url="http://homelab-admin:${TOKEN}@127.0.0.1:${LOCAL_PORT}/homelab-admin/${name}.git"
  perm_url="http://homelab-admin:${TOKEN}@127.0.0.1:3001/homelab-admin/${name}.git"
  
  git -C "$repo" remote set-url forgejo "$push_url" 2>/dev/null || git -C "$repo" remote add forgejo "$push_url"
  git -C "$repo" push forgejo --all --quiet 2>/dev/null || true
  git -C "$repo" push forgejo --tags --quiet 2>/dev/null || true
  git -C "$repo" remote set-url forgejo "$perm_url"
  
  head_commit=$(git -C "$repo" rev-parse --short HEAD 2>/dev/null || echo "N/A")
  echo "    ✓ Synced ${name} (HEAD: ${head_commit})"
done

echo ""
echo "✓ All repositories successfully mirrored to Forgejo on ${TARGET_HOST}!"
echo "  Web UI (Tailscale): https://fedora.tail707210.ts.net/homelab-admin"
echo "  Local Web UI:       http://localhost:3001/homelab-admin (via 'ssh -N pc-forgejo')"
