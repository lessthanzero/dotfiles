#!/usr/bin/env bash
set -e

echo "Updating pacman..."
sudo pacman -Syu --noconfirm

echo "Installing base packages..."
sudo pacman -S --needed --noconfirm - < packages.txt

echo "Applying chezmoi dotfiles..."
chezmoi apply

echo "Done."
