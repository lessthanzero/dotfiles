#!/usr/bin/env bash
# Install Oh My Zsh and Powerlevel10k (idempotent).
# Called from linux/bootstrap.sh and macos/install.sh.
set -euo pipefail

if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
  echo "==> Oh My Zsh (unattended)"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "==> Oh My Zsh already installed"
fi

P10K_DIR="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
  echo "==> Powerlevel10k theme"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  echo "==> Powerlevel10k already cloned"
fi
