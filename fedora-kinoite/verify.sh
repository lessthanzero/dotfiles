#!/usr/bin/env bash
# Sanity checks after Fedora Kinoite bootstrap + chezmoi apply.
set -euo pipefail

FAIL=0
warn() { echo "WARN: $*" >&2; }
fail() { echo "FAIL: $*" >&2; FAIL=1; }
ok() { echo "OK: $*"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> SSH Service"
if systemctl is-active sshd &>/dev/null; then
    ok "SSH service (sshd) is running"
else
    fail "SSH service (sshd) is NOT running. Run: sudo systemctl enable --now sshd"
fi

echo ""
echo "==> Git Configuration"
if [ -n "$(git config --global user.name || true)" ] && [ -n "$(git config --global user.email || true)" ]; then
    ok "Git user.name and user.email are set ($(git config --global user.name) <$(git config --global user.email)>)"
else
    fail "Git user.name or user.email is not set. Check dot_gitconfig.tmpl or chezmoi config."
fi

echo ""
echo "==> Flatpaks"
if [ -f "${SCRIPT_DIR}/packages/flatpaks.txt" ]; then
    installed_flatpaks=$(flatpak list --columns=application)
    while read -r app; do
        [[ "$app" =~ ^# ]] || [[ -z "$app" ]] && continue
        if echo "$installed_flatpaks" | grep -qF "$app"; then
            ok "Flatpak $app is installed"
        else
            fail "Flatpak $app is NOT installed"
        fi
    done < "${SCRIPT_DIR}/packages/flatpaks.txt"
else
    warn "flatpaks.txt package manifest not found, skipping check"
fi

echo ""
echo "==> Tailscale Connection"
if command -v tailscale &>/dev/null; then
    if tailscale status &>/dev/null; then
        ok "Tailscale is connected"
        tailscale status | head -n 5 || true
    else
        warn "Tailscale is installed but not logged in. Run: sudo tailscale up"
    fi
else
    fail "Tailscale CLI is not installed"
fi

echo ""
echo "==> Podman Environment"
if command -v podman &>/dev/null; then
    if podman ps &>/dev/null; then
        ok "Podman is installed and responding (rootless)"
    else
        fail "Podman is installed but not responding to 'podman ps'"
    fi
else
    fail "Podman CLI is not installed"
fi

echo ""
echo "==> Ollama Service"
if curl -s -f http://localhost:11434/api/tags &>/dev/null; then
    ok "Ollama is responding at http://localhost:11434"
else
    if systemctl --user is-active ollama &>/dev/null; then
        warn "Ollama user service is active but not responding to HTTP requests."
    else
        fail "Ollama service is NOT running/responding."
    fi
fi

echo ""
if [[ "$FAIL" -eq 0 ]]; then
    echo "============================================="
    echo "All required checks passed successfully!"
    echo "============================================="
else
    echo "============================================="
    echo "Some verification checks FAILED. Please review the output above."
    echo "============================================="
    exit 1
fi
