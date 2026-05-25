#!/usr/bin/env bash
# Linux Mint / Debian: lightweight bootstrap (full setup: linux/bootstrap.sh).
# APT CLI packages + chezmoi apply (OMZ/p10k via run_once or scripts/install-omz-p10k.sh).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Updating apt..."
sudo apt update

echo "Installing CLI packages (see linux/mint-apt-cli.txt)..."
sudo apt install -y \
  tmux bat ripgrep fd-find eza lnav starship zsh zoxide btop gh kitty curl git

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "chezmoi not found; install from https://chezmoi.io/get then re-run."
  exit 1
fi

echo "Installing Oh My Zsh + Powerlevel10k..."
bash "${REPO_ROOT}/scripts/install-omz-p10k.sh"

echo "Applying chezmoi dotfiles..."
chezmoi apply

echo ""
echo "Done. For full Mint laptop setup also run:"
echo "  bash linux/bootstrap.sh"
echo "  bash linux/xfce-ux-mint.sh"
echo "  bash linux/install-nerd-font-jetbrains.sh"
echo "Optional: chsh -s \"\$(command -v zsh)\"; code --install-extension enkia.tokyo-night"
