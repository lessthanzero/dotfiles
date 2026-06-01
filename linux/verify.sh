#!/usr/bin/env bash
# Sanity checks after Linux Mint bootstrap + chezmoi apply. See docs/terminal-ux.md.
set -euo pipefail

FAIL=0
warn() { echo "WARN: $*" >&2; }
fail() { echo "FAIL: $*" >&2; FAIL=1; }
ok() { echo "OK: $*"; }

echo "==> CLI binaries"
REQUIRED=(git zsh tmux kitty batcat fdfind rg eza zoxide btop gh chezmoi)
for c in "${REQUIRED[@]}"; do
  if command -v "$c" >/dev/null 2>&1; then
    ok "$c"
  else
    fail "missing: $c"
  fi
done

for c in uv starship; do
  command -v "$c" >/dev/null 2>&1 && ok "$c" || warn "optional missing: $c"
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
echo "==> Nerd Font"
if fc-match "JetBrainsMono Nerd Font" 2>/dev/null | grep -q 'Nerd Font'; then
  ok "JetBrains Mono Nerd Font"
else
  fail "JetBrains Mono Nerd Font not found — run linux/install-nerd-font-jetbrains.sh"
fi

echo ""
echo "==> Kitty config"
[[ -f "${HOME}/.config/kitty/kitty.conf" ]] && ok "kitty.conf" || warn "kitty.conf missing (chezmoi apply?)"

echo ""
echo "==> XFCE default terminal"
if command -v xfconf-query >/dev/null 2>&1 && [[ -n "${DISPLAY:-}" ]]; then
  term="$(xfconf-query -c exo-preferred-applications -p /TerminalEmulator 2>/dev/null || true)"
  if [[ "$term" == "kitty" ]]; then
    ok "TerminalEmulator=kitty"
  else
    warn "TerminalEmulator='${term:-unset}' (expected kitty) — run linux/xfce-ux-mint.sh"
  fi
else
  warn "skipping TerminalEmulator check (no DISPLAY or xfconf-query)"
fi

echo ""
echo "==> Super+arrow window shortcuts"
if command -v xfconf-query >/dev/null 2>&1 && [[ -n "${DISPLAY:-}" ]]; then
  left="$(xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/<Super>Left' 2>/dev/null || true)"
  right="$(xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/<Super>Right' 2>/dev/null || true)"
  up="$(xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/<Super>Up' 2>/dev/null || true)"
  down="$(xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/<Super>Down' 2>/dev/null || true)"
  super_l="$(xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/Super_L' 2>/dev/null || true)"
  [[ "$left" == *xfce-tile-left.sh ]] && ok "Super+Left → tile" || warn "Super+Left not set to tile script ($left)"
  [[ "$right" == *xfce-tile-right.sh ]] && ok "Super+Right → tile" || warn "Super+Right not set to tile script ($right)"
  [[ "$up" == *xfce-window-maximize.sh ]] && ok "Super+Up → maximize" || warn "Super+Up not set ($up)"
  [[ "$down" == *xfce-window-restore.sh ]] && ok "Super+Down → restore" || warn "Super+Down not set ($down)"
  [[ "$super_l" == "/usr/bin/true" ]] && ok "Super_L whiskermenu overridden" || warn "Super_L not overridden ($super_l) — Mint default whiskermenu blocks Super+arrow"
  command -v wmctrl >/dev/null 2>&1 && ok "wmctrl" || warn "wmctrl missing (required for window scripts)"
else
  warn "skipping window shortcut check"
fi

echo ""
echo "==> TLP (laptop)"
if systemctl is-enabled tlp &>/dev/null; then
  ok "tlp enabled"
elif dpkg -l tlp &>/dev/null 2>&1; then
  warn "tlp installed but not enabled"
else
  warn "tlp not installed (optional unless --laptop)"
fi

echo ""
if [[ "$FAIL" -eq 0 ]]; then
  echo "All required checks passed."
else
  echo "Some checks failed."
  exit 1
fi
