#!/usr/bin/env bash
# chezmoi run_once: Oh My Zsh + Powerlevel10k (delegates to scripts/install-omz-p10k.sh)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "${SCRIPT_DIR}/scripts/install-omz-p10k.sh"
