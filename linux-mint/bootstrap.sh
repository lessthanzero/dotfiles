#!/usr/bin/env bash
# Linux Mint 22.x (Ubuntu Noble) / Debian: full dev bootstrap.
# APT CLI packages + chezmoi/uv/starship + Oh My Zsh + Powerlevel10k (+ optional laptop packages).
#
# Usage:
#   bash linux/bootstrap.sh              # standard dev laptop
#   bash linux/bootstrap.sh --laptop   # also TLP/powertop (MacBook Air, etc.)
#   bash linux/bootstrap.sh --skip-omz   # APT/tools only
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAPTOP=false
SKIP_OMZ=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --laptop) LAPTOP=true ;;
    --skip-omz) SKIP_OMZ=true ;;
    -h|--help)
      echo "Usage: $0 [--laptop] [--skip-omz]"
      exit 0
      ;;
    *)
      echo "Usage: $0 [--laptop] [--skip-omz]" >&2
      exit 1
      ;;
  esac
  shift
done

read_packages() {
  grep -v '^#' "$1" | grep -v '^[[:space:]]*$' || true
}

echo "==> CLI packages and user tools (chezmoi, uv, starship)"
bash "${SCRIPT_DIR}/bootstrap-cli.sh"

if [[ "$LAPTOP" == true ]]; then
  MANIFEST="${SCRIPT_DIR}/mint-apt-laptop.txt"
  if [[ -f "$MANIFEST" ]]; then
    mapfile -t pkgs < <(read_packages "$MANIFEST")
    if [[ ${#pkgs[@]} -gt 0 ]]; then
      echo "==> Laptop packages (TLP, etc.)"
      sudo apt-get install -y "${pkgs[@]}"
      if systemctl list-unit-files tlp.service &>/dev/null; then
        sudo systemctl enable tlp || true
        sudo systemctl start tlp || true
      fi
    fi
  fi
fi

if [[ "$SKIP_OMZ" == false ]]; then
  bash "${SCRIPT_DIR}/../scripts/install-omz-p10k.sh"
fi

echo ""
echo "Bootstrap complete. Next:"
echo "  1. chezmoi init --apply <path-to-this-repo>   # or: chezmoi apply"
echo "  2. bash linux/xfce-ux-mint.sh                 # XFCE: themes, Kitty default, shortcuts"
echo "  3. bash linux/install-nerd-font-jetbrains.sh  # Nerd Font for Kitty / P10k / Cursor"
echo "  4. bash linux/verify.sh"
echo "  5. Optional: chsh -s \"\$(command -v zsh)\""
echo "  6. Optional: bash linux/run_once_install_flatpaks.sh"
echo "  7. Optional: cursor --install-extension enkia.tokyo-night"
