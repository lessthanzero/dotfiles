#!/usr/bin/env bash
# Sanity checks after macOS bootstrap + chezmoi apply. See docs/terminal-ux.md.
set -euo pipefail

FAIL=0
warn() { echo "WARN: $*" >&2; }
fail() { echo "FAIL: $*" >&2; FAIL=1; }
ok() { echo "OK: $*"; }

echo "==> CLI binaries"
REQUIRED=(git zsh tmux bat fd rg eza lnav zoxide btop gh chezmoi uv)
for c in "${REQUIRED[@]}"; do
  if command -v "$c" >/dev/null 2>&1; then
    ok "$c"
  else
    fail "missing: $c"
  fi
done

echo ""
echo "==> Oh My Zsh + Powerlevel10k"
[[ -d "${HOME}/.oh-my-zsh" ]] && ok "oh-my-zsh" || fail "oh-my-zsh not installed"
[[ -d "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k" ]] && ok "powerlevel10k" || fail "powerlevel10k not cloned"

echo ""
echo "==> Chezmoi"
if command -v chezmoi >/dev/null 2>&1; then
  chezmoi doctor 2>&1 | tail -5 || warn "chezmoi doctor reported issues"
  ok "chezmoi present"
else
  fail "chezmoi not in PATH"
fi

echo ""
echo "==> Dotfiles (chezmoi apply)"
[[ -f "${HOME}/.zshrc" ]] && ok ".zshrc" || warn ".zshrc missing (chezmoi apply?)"
[[ -f "${HOME}/.p10k.zsh" ]] && ok ".p10k.zsh" || warn ".p10k.zsh missing (chezmoi apply?)"

echo ""
echo "==> Nerd Font"
nerd_font_ok=false
if fc-list 2>/dev/null | grep -qi 'jetbrains.*nerd'; then
  nerd_font_ok=true
  ok "JetBrains Mono Nerd Font (fontconfig)"
elif compgen -G "${HOME}/Library/Fonts/JetBrainsMono*Nerd*" >/dev/null 2>&1; then
  nerd_font_ok=true
  ok "JetBrains Mono Nerd Font (~/Library/Fonts)"
elif compgen -G "/Library/Fonts/JetBrainsMono*Nerd*" >/dev/null 2>&1; then
  nerd_font_ok=true
  ok "JetBrains Mono Nerd Font (/Library/Fonts)"
fi
if [[ "$nerd_font_ok" == false ]]; then
  fail "JetBrains Mono Nerd Font not found — brew install --cask font-jetbrains-mono-nerd-font"
fi

echo ""
echo "==> Homebrew"
if command -v brew >/dev/null 2>&1; then
  ok "brew"
else
  fail "brew not in PATH"
fi

echo ""
if [[ "$FAIL" -eq 0 ]]; then
  echo "All required checks passed."
else
  echo "Some checks failed."
  exit 1
fi
