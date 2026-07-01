#!/usr/bin/env bash
# chezmoi run_once: Install Antigravity CLI (agy)
set -euo pipefail

if ! command -v agy &> /dev/null; then
  echo "Installing Antigravity CLI..."
  curl -fsSL https://antigravity.google/cli/install.sh | bash
else
  echo "Antigravity CLI (agy) is already installed."
fi
