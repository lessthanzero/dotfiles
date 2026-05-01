#!/usr/bin/env bash
# Arch laptop / standard Arch Linux: updates system packages and applies chezmoi.
# NOT recommended on SteamOS / Steam Deck: immutable OS, read-only root, and
# SteamOS updates differ from Arch. Prefer user-level configs (chezmoi apply
# only) and install CLI tools via distrobox, flatpak, or SteamOS-approved paths.
# See docs/terminal-ux.md.
set -e

echo "Updating pacman..."
sudo pacman -Syu --noconfirm

echo "Installing base packages..."
sudo pacman -S --needed --noconfirm - < packages.txt

echo "Installing Powerlevel10k theme into ~/.oh-my-zsh/custom/themes (clone Oh My Zsh first if needed)..."
mkdir -p "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" 2>/dev/null \
  || true

echo "Applying chezmoi dotfiles..."
chezmoi apply

echo "Done."
