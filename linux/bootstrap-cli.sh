#!/usr/bin/env bash
# Debian / Ubuntu / Linux Mint 22.x (Noble): APT CLI packages aligned with ../packages.txt
# plus tools missing from APT (chezmoi, uv, starship). Prefer linux/bootstrap.sh for full setup.
# Does not install Obsidian (use Flatpak or browser).
set -euo pipefail

PATH="$HOME/.local/bin:$PATH"

APT_PACKAGES=(
  git
  curl
  wget
  zsh
  tmux
  kitty
  bat
  ripgrep
  fd-find
  eza
  lnav
  zoxide
  btop
  gh
  keychain
)

echo "Updating APT and installing CLI packages..."
sudo apt-get update
sudo apt-get install -y "${APT_PACKAGES[@]}"

have() {
  command -v "$1" >/dev/null 2>&1
}

mkdir -p "$HOME/.local/bin"

if ! have chezmoi; then
  echo "Installing chezmoi to ~/.local/bin ..."
  curl -fsSL https://chezmoi.io/get | bash -s -- -b "$HOME/.local/bin"
fi

if ! have uv; then
  echo "Installing uv (Astral) ..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

if ! have starship; then
  echo "Installing Starship (bash prompt; zsh uses Powerlevel10k) ..."
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
fi

echo ""
echo "APT CLI install done. For full Mint setup run: bash linux/bootstrap.sh"
echo "Node: use nvm (see ~/.zshrc), not apt nodejs, unless you know you need system Node."
