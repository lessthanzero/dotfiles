#!/usr/bin/env bash
# Lean XFCE UX for Linux Mint / Ubuntu XFCE (see linux/mint-apt-xfce-ux.txt).
# Run from a graphical session (DISPLAY set). xfconf runs as the invoking user;
# use sudo only for apt — do not run the whole script as root without SUDO_USER.
#
# Usage:
#   bash linux/xfce-ux-mint.sh
#   bash linux/xfce-ux-mint.sh --apt-only
#   bash linux/xfce-ux-mint.sh --xfconf-only
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="${SCRIPT_DIR}/mint-apt-xfce-ux.txt"

APT_ONLY=false
XFCONF_ONLY=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --apt-only) APT_ONLY=true ;;
    --xfconf-only) XFCONF_ONLY=true ;;
    *)
      echo "Usage: $0 [--apt-only|--xfconf-only]" >&2
      exit 1
      ;;
  esac
  shift
done

if [[ "$APT_ONLY" == true && "$XFCONF_ONLY" == true ]]; then
  echo "Choose at most one of --apt-only or --xfconf-only." >&2
  exit 1
fi

read_packages() {
  grep -v '^#' "$MANIFEST" | grep -v '^[[:space:]]*$' || true
}

run_apt() {
  local pkgs
  mapfile -t pkgs < <(read_packages)
  if [[ ${#pkgs[@]} -eq 0 ]]; then
    echo "No packages listed in $MANIFEST" >&2
    return 1
  fi
  sudo apt-get update
  sudo apt-get install -y "${pkgs[@]}"
}

xfconf_run() {
  local -a env_prefix=(env)
  if [[ -n "${DISPLAY:-}" ]]; then
    env_prefix+=(DISPLAY="$DISPLAY")
  fi
  if [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    env_prefix+=(DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS")
  fi

  if [[ "$(id -u)" -eq 0 ]]; then
    if [[ -z "${SUDO_USER:-}" ]]; then
      echo "xfconf: cannot run as root without SUDO_USER; run this script as your desktop user." >&2
      return 1
    fi
    sudo -u "$SUDO_USER" "${env_prefix[@]}" xfconf-query "$@"
  else
    "${env_prefix[@]}" xfconf-query "$@"
  fi
}

xfconf_set_string() {
  local channel=$1 prop=$2 val=$3
  if xfconf_run -c "$channel" -p "$prop" -v &>/dev/null; then
    xfconf_run -c "$channel" -p "$prop" -s "$val"
  else
    xfconf_run -c "$channel" -p "$prop" -n -t string -s "$val"
  fi
}

xfconf_set_bool() {
  local channel=$1 prop=$2 val=$3
  if xfconf_run -c "$channel" -p "$prop" -v &>/dev/null; then
    xfconf_run -c "$channel" -p "$prop" -s "$val"
  else
    xfconf_run -c "$channel" -p "$prop" -n -t bool -s "$val"
  fi
}

desktop_user_run() {
  local -a cmd=(env)
  [[ -n "${DISPLAY:-}" ]] && cmd+=(DISPLAY="$DISPLAY")
  [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]] && cmd+=(DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS")
  cmd+=("$@")
  if [[ "$(id -u)" -eq 0 ]]; then
    if [[ -z "${SUDO_USER:-}" ]]; then
      echo "desktop_user_run: need SUDO_USER when root." >&2
      return 1
    fi
    sudo -u "$SUDO_USER" "${cmd[@]}"
  else
    "${cmd[@]}"
  fi
}

run_xfconf() {
  if [[ "$(id -u)" -eq 0 && -z "${SUDO_USER:-}" ]]; then
    echo "Do not run xfconf as root without SUDO_USER; use your normal desktop user." >&2
    return 1
  fi
  if [[ -z "${DISPLAY:-}" ]]; then
    echo "Skipping xfconf: DISPLAY is unset (open a normal XFCE session)." >&2
    return 1
  fi
  if ! command -v xfconf-query &>/dev/null; then
    echo "Skipping xfconf: xfconf-query not in PATH." >&2
    return 1
  fi

  echo "==> exo: default terminal emulator (Kitty)"
  xfconf_set_string exo-preferred-applications /TerminalEmulator 'kitty'

  echo "==> xsettings: theme / icons / cursor (fonts unchanged)"
  xfconf_set_string xsettings /Net/ThemeName 'Arc-Dark'
  xfconf_set_string xsettings /Net/IconThemeName 'Papirus'
  xfconf_set_string xsettings /Gtk/CursorThemeName 'Bibata-Modern-Classic'

  echo "==> xfwm4: mouse edge tiling"
  xfconf_set_bool xfwm4 /general/tile_on_move true

  echo "==> xfwm4 keyboard: Super+arrows (xfwm4 action ids on /xfwm4/custom/)"
  xfconf_set_string xfce4-keyboard-shortcuts '/xfwm4/custom/<Super>Left' tile_left_key
  xfconf_set_string xfce4-keyboard-shortcuts '/xfwm4/custom/<Super>Right' tile_right_key
  xfconf_set_string xfce4-keyboard-shortcuts '/xfwm4/custom/<Super>Up' maximize_window_key

  echo "==> Neutralize <Super>r (Mint default runs xfce4-appfinder and blocks Super+Right unless fully overridden)"
  xfconf_set_string xfce4-keyboard-shortcuts '/commands/custom/<Super>r' '/usr/bin/true'
  xfconf_run -c xfce4-keyboard-shortcuts -p '/commands/default/<Super>r' -s '' 2>/dev/null || true

  echo "==> App finder (xfce4-appfinder -c) on Super+Page Down (replaces old Super+r; Win+Right stays tile-right)"
  xfconf_set_string xfce4-keyboard-shortcuts '/commands/custom/<Super>Page_Down' 'xfce4-appfinder -c'
  xfconf_set_bool xfce4-keyboard-shortcuts '/commands/custom/<Super>Page_Down/startup-notify' true

  echo "==> Reload panel"
  if command -v xfce4-panel &>/dev/null; then
    desktop_user_run xfce4-panel -r 2>/dev/null || true
  fi

  cat <<'EOF'

Manual steps (not automated):
  • Whisker Menu: do not bind to Super alone (blocks Super+arrow on X11). Use Super+Space or Alt+F1.
  • Super+Left/Right/Up tiling only works after Whisker is remapped away from Super.
  • Super+r is overridden (/usr/bin/true + cleared default) so Super+Right reaches xfwm4. App finder: Super+Page Down; Alt+F3 = full finder.
  • Optional: sudo apt install xfce4-whiskermenu-plugin xfce4-docklike-plugin — then add plugins and remove default taskbar in Panel preferences.
  • Run qt5ct once and pick a GTK-friendly Qt style (e.g. Arc / Fusion + palette).
  • Qt6 apps: install qt6ct if needed and set QT_QPA_PLATFORMTHEME=qt6ct (see ~/.config/environment.d/ after chezmoi apply).
  • Notifications: Settings → Notifications → position / timeout.
  • Session startup: Settings → Session and Startup → disable unwanted entries.
  • Tearing: try xfconf-query -c xfwm4 -p /general/vblank_mode -s glx or xpresent.

Thunar “Open Terminal Here”: chezmoi applies ~/.config/Thunar/uca.xml (Kitty). Default terminal: Kitty via exo-preferred-applications.

EOF
}

main() {
  if [[ "$XFCONF_ONLY" == true ]]; then
    run_xfconf
    return 0
  fi

  if [[ "$APT_ONLY" == true ]]; then
    run_apt
    return 0
  fi

  run_apt
  echo ""
  run_xfconf || true
}

main "$@"
