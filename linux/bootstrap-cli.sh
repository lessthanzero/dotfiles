#!/usr/bin/env bash
# Debian / Ubuntu / Linux Mint: install CLI packages aligned with ../packages.txt plus tools
# missing from APT (chezmoi, uv, starship). Does not install Obsidian (use Flatpak or browser).
# Pair with chezmoi apply after Oh My Zsh + Powerlevel10k are installed (see README).
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
echo "Done. Next:"
echo "  1. Install Oh My Zsh: https://ohmyz.sh/#install"
echo "  2. git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \\"
echo "       \"\${ZSH_CUSTOM:-\$HOME/.oh-my-zsh/custom}/themes/powerlevel10k\""
echo "  3. chezmoi apply"
echo "  4. Optional: chsh -s \"\$(command -v zsh)\""
echo "Node: use nvm (see ~/.zshrc), not apt nodejs, unless you know you need system Node."
