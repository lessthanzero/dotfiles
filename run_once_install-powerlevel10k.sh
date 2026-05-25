#!/usr/bin/env bash
# chezmoi run_once: Oh My Zsh + Powerlevel10k (idempotent)
set -euo pipefail
SOURCE="$(chezmoi source-path)"
bash "${SOURCE}/scripts/install-omz-p10k.sh"
