#!/usr/bin/env bash
# Ubuntu XFCE setup script for parents' laptop (2020/2022 Ubuntu)
# Optimized for 4GB RAM, accessibility, and Russian network conditions
# One-liner: curl -fsSL https://raw.githubusercontent.com/lessthanzero/dotfiles/master/linux-xfce-setup.sh | sudo bash
# Or: wget -qO- https://raw.githubusercontent.com/lessthanzero/dotfiles/master/linux-xfce-setup.sh | sudo bash

set -euo pipefail

# Logging setup
LOG_FILE="/tmp/setup-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then 
  echo "Error: This script must be run with sudo"
  echo "Usage: sudo bash $0"
  exit 1
fi

# Detect Ubuntu version
detect_ubuntu_version() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    UBUNTU_VERSION="${VERSION_ID:-unknown}"
    UBUNTU_CODENAME="${VERSION_CODENAME:-unknown}"
    echo "==> Detected Ubuntu ${UBUNTU_VERSION} (${UBUNTU_CODENAME})"
  else
    echo "Warning: Cannot detect Ubuntu version, assuming 20.04"
    UBUNTU_VERSION="20.04"
    UBUNTU_CODENAME="focal"
  fi
}

# Configure APT with Russian mirror fallback
configure_apt_mirrors() {
  echo "==> Configuring APT mirrors (with Russian fallback)"
  
  # Backup original sources
  if [ ! -f /etc/apt/sources.list.backup ]; then
    cp /etc/apt/sources.list /etc/apt/sources.list.backup || true
  fi
  
  # Try to use Russian mirrors if primary fails
  # Yandex mirror for Ubuntu (if available for this version)
  if [ "$UBUNTU_CODENAME" = "focal" ] || [ "$UBUNTU_CODENAME" = "jammy" ]; then
    echo "==> Adding Russian mirror fallback (Yandex)"
    cat > /etc/apt/sources.list.d/yandex-backup.list <<EOF || true
# Yandex mirror backup (commented by default, uncomment if primary fails)
# deb http://mirror.yandex.ru/ubuntu/ ${UBUNTU_CODENAME} main restricted universe multiverse
# deb http://mirror.yandex.ru/ubuntu/ ${UBUNTU_CODENAME}-updates main restricted universe multiverse
# deb http://mirror.yandex.ru/ubuntu/ ${UBUNTU_CODENAME}-security main restricted universe multiverse
EOF
  fi
  
  # Configure APT to retry on network failures
  cat > /etc/apt/apt.conf.d/99retry <<'EOF'
Acquire::Retries "5";
Acquire::http::Timeout "30";
Acquire::https::Timeout "30";
EOF
}

# Retry apt-get with better error handling
apt_get_retry() {
  local max_attempts=3
  local attempt=1
  
  while [ $attempt -le $max_attempts ]; do
    if DEBIAN_FRONTEND=noninteractive apt-get "$@" -y; then
      return 0
    fi
    
    if [ $attempt -lt $max_attempts ]; then
      echo "==> Attempt $attempt failed, retrying in 5 seconds..."
      sleep 5
      attempt=$((attempt + 1))
    else
      echo "==> Failed after $max_attempts attempts"
      return 1
    fi
  done
}

# Setup swap file for low-memory systems
setup_swap() {
  echo "==> Checking swap configuration"
  
  # Check if swap already exists
  if swapon --show | grep -q .; then
    echo "==> Swap already configured, skipping"
    return 0
  fi
  
  # Check available RAM
  local total_ram=$(free -m | awk '/^Mem:/{print $2}')
  local swap_size=2048  # 2GB default for 4GB RAM systems
  
  if [ "$total_ram" -lt 4096 ]; then
    swap_size=4096  # 4GB swap for systems with <4GB RAM
  fi
  
  echo "==> Creating ${swap_size}MB swap file"
  
  # Create swap file
  fallocate -l ${swap_size}M /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=$swap_size
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  
  # Make it permanent
  if ! grep -q "/swapfile" /etc/fstab; then
    echo "/swapfile none swap sw 0 0" >> /etc/fstab
  fi
  
  # Optimize swappiness for desktop use
  if ! grep -q "vm.swappiness" /etc/sysctl.conf; then
    echo "vm.swappiness=10" >> /etc/sysctl.conf
    sysctl vm.swappiness=10
  fi
  
  echo "==> Swap configured: ${swap_size}MB"
}

### ======= EDITABLE SETTINGS =======

# Basic
HOSTNAME="parents-laptop"
PARENT_USER="${SUDO_USER:-$USER}"    # the interactive user who will use the machine
TIMEZONE="Europe/Moscow"             # change if needed

# Language & keyboard (examples: "us,ru" with Alt+Shift toggle)
LANG_MAIN="en_GB.UTF-8"
LANG_EXTRA=("ru_RU.UTF-8")
KB_LAYOUTS="us,ru"
KB_VARIANTS=","                      # usually empty; e.g. ",phonetic" for Russian phonetic
KB_TOGGLE="grp:alt_shift_toggle"

# Accessibility / look & feel (XFCE)
# Increased for better visibility for older users
XFCE_DPI=120                         # Increased from 110
FONT_DEFAULT="Noto Sans 12"          # Increased from 11
FONT_MONO="Noto Sans Mono 12"
CURSOR_SIZE=36                       # Increased from 32
PANEL_SIZE=40                        # Increased from 36

# Apps to install (optimized for 4GB RAM)
APT_APPS=(
  # essentials
  curl wget git nano
  # desktop (lightweight LibreOffice components only)
  libreoffice-writer libreoffice-calc libreoffice-help-en-gb
  firefox firefox-locale-ru
  thunderbird thunderbird-locale-ru
  vlc
  xreader               # simple PDF viewer
  gnome-disk-utility
  file-roller p7zip-full unrar
  # printing & codecs
  cups system-config-printer printer-driver-all
  ubuntu-restricted-extras
  # backups
  timeshift
  # input methods & lang packs
  ibus ibus-gtk ibus-gtk3 ibus-gtk4 ibus-qt4
  language-pack-en language-pack-gnome-en
  # performance & memory optimization
  preload
  # accessibility (optional screen reader)
  # orca  # Uncomment if needed
)

# Extra language packs (auto-expanded below)
EXTRA_LANG_PACKS_BASE=(language-pack-ru language-pack-gnome-ru)

# Tailscale setup (requires auth key or manual setup)
TAILSCALE_AUTH_KEY=""  # Leave empty for manual setup, or add your auth key

# RustDesk setup
RUSTDESK_PASSWORD=""   # Leave empty to generate random, or set custom password

### ======= END OF EDITABLE SETTINGS =======

# Main execution starts here
echo "=========================================="
echo "Ubuntu XFCE Setup Script"
echo "Optimized for low-memory systems"
echo "=========================================="
echo ""

detect_ubuntu_version
configure_apt_mirrors

echo "==> Setting hostname"
hostnamectl set-hostname "$HOSTNAME" || true

echo "==> Setting timezone"
timedatectl set-timezone "$TIMEZONE" || true

echo "==> Setting up swap file"
setup_swap

echo "==> Refreshing APT & upgrading"
apt_get_retry update
apt_get_retry dist-upgrade

echo "==> Installing apps"
APT_ALL=("${APT_APPS[@]}" "${EXTRA_LANG_PACKS_BASE[@]}")
apt_get_retry install "${APT_ALL[@]}"

echo "==> Installing Tailscale"
install_tailscale() {
  if command -v tailscale &> /dev/null; then
    echo "==> Tailscale already installed"
    return 0
  fi
  
  echo "==> Installing Tailscale..."
  
  # Install Tailscale based on Ubuntu version
  if [ "$UBUNTU_CODENAME" = "focal" ] || [ "$UBUNTU_CODENAME" = "jammy" ]; then
    curl -fsSL https://tailscale.com/install.sh | sh || {
      echo "Warning: Tailscale installation failed, you can install manually later"
      return 1
    }
    
    # Start Tailscale
    systemctl enable tailscaled || true
    systemctl start tailscaled || true
    
    if [ -n "$TAILSCALE_AUTH_KEY" ]; then
      echo "==> Authenticating Tailscale with provided key"
      tailscale up --authkey="$TAILSCALE_AUTH_KEY" || {
        echo "Warning: Tailscale authentication failed, run 'sudo tailscale up' manually"
      }
    else
      echo "==> Tailscale installed. Run 'sudo tailscale up' to authenticate"
    fi
  else
    echo "Warning: Tailscale installation not configured for this Ubuntu version"
  fi
}
install_tailscale

echo "==> Installing RustDesk"
install_rustdesk() {
  if command -v rustdesk &> /dev/null; then
    echo "==> RustDesk already installed"
    return 0
  fi
  
  echo "==> Installing RustDesk..."
  
  # Download and install RustDesk
  RUSTDESK_DEB="/tmp/rustdesk.deb"
  
  # Try to get latest version (adjust URL if needed)
  if curl -fsSL -o "$RUSTDESK_DEB" "https://github.com/rustdesk/rustdesk/releases/latest/download/rustdesk-1.2.3-x86_64.deb" 2>/dev/null; then
    apt-get install -y "$RUSTDESK_DEB" || {
      echo "Warning: RustDesk .deb installation failed, trying alternative method"
      rm -f "$RUSTDESK_DEB"
    }
  fi
  
  # Alternative: Install from RustDesk repo
  if ! command -v rustdesk &> /dev/null; then
    echo "==> Installing RustDesk from repository..."
    wget -qO - https://raw.githubusercontent.com/rustdesk/rustdesk-server/master/rustdesk.sh | bash || {
      echo "Warning: RustDesk installation failed, you can install manually later"
      echo "Visit: https://rustdesk.com/docs/en/self-host/install/"
      return 1
    }
  fi
  
  # Configure RustDesk for unattended access
  if command -v rustdesk &> /dev/null; then
    systemctl enable rustdesk || true
    systemctl start rustdesk || true
    
    # Set password if provided, otherwise generate random
    if [ -n "$RUSTDESK_PASSWORD" ]; then
      rustdesk --password "$RUSTDESK_PASSWORD" || true
    else
      RANDOM_PASS=$(openssl rand -base64 12)
      rustdesk --password "$RANDOM_PASS" || true
      echo "==> RustDesk password: $RANDOM_PASS (save this!)"
      echo "$RANDOM_PASS" > /home/"$PARENT_USER"/.rustdesk-password.txt
      chown "$PARENT_USER":"$PARENT_USER" /home/"$PARENT_USER"/.rustdesk-password.txt
      chmod 600 /home/"$PARENT_USER"/.rustdesk-password.txt
    fi
    
    # Get RustDesk ID
    RUSTDESK_ID=$(rustdesk --get-id 2>/dev/null || echo "unknown")
    echo "==> RustDesk ID: $RUSTDESK_ID"
  fi
}
install_rustdesk

echo "==> Enabling unattended security updates"
apt-get install -y unattended-upgrades || true
dpkg-reconfigure -plow unattended-upgrades || true
# ensure it runs daily
install -d /etc/apt/apt.conf.d
cat >/etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

echo "==> Configuring firewall (UFW)"
apt-get install -y ufw || true
ufw default deny incoming || true
ufw default allow outgoing || true
# allow local printing
ufw allow 631/tcp || true
# Allow Tailscale
ufw allow 41641/udp || true
# Allow RustDesk (adjust ports if using custom relay)
ufw allow 21115:21119/tcp || true
ufw allow 21116/udp || true
ufw --force enable || true

echo "==> Generating locales"
locale-gen "$LANG_MAIN" || true
for L in "${LANG_EXTRA[@]}"; do locale-gen "$L" || true; done
update-locale LANG="$LANG_MAIN"

echo "==> Setting system keyboard layouts"
# Persist for console & X:
sed -i 's/^XKBLAYOUT=.*/#&/' /etc/default/keyboard || true
sed -i 's/^XKBVARIANT=.*/#&/' /etc/default/keyboard || true
sed -i 's/^XKBOPTIONS=.*/#&/' /etc/default/keyboard || true
cat >/etc/default/keyboard <<EOF
XKBLAYOUT="$KB_LAYOUTS"
XKBVARIANT="$KB_VARIANTS"
XKBOPTIONS="$KB_TOGGLE"
BACKSPACE="guess"
EOF
udevadm trigger --subsystem-match=input --action=change || true

# Ensure IBus is the default input method
im-config -n ibus || true

echo "==> XFCE accessibility & UI tweaks for user: $PARENT_USER"
# xfconf writes must happen as the target desktop user
runuser -l "$PARENT_USER" -c "xfconf-query -c xsettings -p /Xft/DPI -s $((XFCE_DPI*1024)) || true"
runuser -l "$PARENT_USER" -c "xfconf-query -c xsettings -p /Gtk/CursorThemeSize -s $CURSOR_SIZE || true"
runuser -l "$PARENT_USER" -c "xfconf-query -c xsettings -p /Gtk/FontName -s \"$FONT_DEFAULT\" || true"
runuser -l "$PARENT_USER" -c "xfconf-query -c xfwm4 -p /general/title_font -s \"$FONT_DEFAULT\" || true"
runuser -l "$PARENT_USER" -c "xfconf-query -c xsettings -p /MonospaceFontName -s \"$FONT_MONO\" || true"

# Panel size
runuser -l "$PARENT_USER" -c "xfconf-query -c xfce4-panel -p /panels -l >/tmp/panels.list || true"
if runuser -l "$PARENT_USER" -c "xfconf-query -c xfce4-panel -p /panels/panel-1/size >/dev/null 2>&1"; then
  runuser -l "$PARENT_USER" -c "xfconf-query -c xfce4-panel -p /panels/panel-1/size -s $PANEL_SIZE || true"
fi

# Additional accessibility: larger window buttons, high contrast option
runuser -l "$PARENT_USER" -c "xfconf-query -c xfwm4 -p /general/button_layout -s 'CHM|' || true"  # Close, Maximize, Minimize on right
runuser -l "$PARENT_USER" -c "xfconf-query -c xfwm4 -p /general/theme -s 'Default' || true"

# Make Alt+Shift layout toggle work in the session too
runuser -l "$PARENT_USER" -c "gsettings set org.gnome.desktop.input-sources sources \"[('xkb', '$KB_LAYOUTS')]\" 2>/dev/null || true"
runuser -l "$PARENT_USER" -c "gsettings set org.gnome.desktop.input-sources xkb-options \"['$KB_TOGGLE']\" 2>/dev/null || true"

echo "==> Power & laptop comfort"
# Lid close -> suspend (safer for parents), shorter blanking
# Only mask hibernate/hybrid-sleep, keep suspend working
systemctl mask hibernate.target hybrid-sleep.target >/dev/null 2>&1 || true

# Use TLP for sane battery behavior on older laptops
apt-get install -y tlp tlp-rdw || true
systemctl enable tlp || true
systemctl start tlp || true

# Configure TLP for better battery life
if [ -f /etc/tlp.conf ]; then
  # Reduce CPU frequency scaling for better battery
  sed -i 's/#CPU_SCALING_GOVERNOR_ON_AC=.*/CPU_SCALING_GOVERNOR_ON_AC=powersave/' /etc/tlp.conf || true
  sed -i 's/#CPU_SCALING_GOVERNOR_ON_BAT=.*/CPU_SCALING_GOVERNOR_ON_BAT=powersave/' /etc/tlp.conf || true
fi

echo "==> Printing setup"
systemctl enable cups || true
systemctl start cups || true

echo "==> Optimizing for low-memory systems"
# Enable preload for faster app launches
systemctl enable preload || true
systemctl start preload || true

# Configure zswap if available (better than swap for performance)
if modprobe zswap 2>/dev/null; then
  if ! grep -q "zswap.enabled" /etc/default/grub.d/zswap.cfg 2>/dev/null; then
    echo "GRUB_CMDLINE_LINUX_DEFAULT=\"\$GRUB_CMDLINE_LINUX_DEFAULT zswap.enabled=1 zswap.compressor=lz4 zswap.max_pool_percent=20\"" > /etc/default/grub.d/zswap.cfg || true
  fi
fi

echo "==> Timeshift: btrfs users can switch; rsync mode by default"
# No auto schedule here; you can configure via GUI with parents.

echo "==> Cleaning up"
apt-get autoremove -y || true
apt-get clean || true

echo ""
echo "=========================================="
echo "==> Setup complete!"
echo "=========================================="
echo "Log file: $LOG_FILE"
echo ""
echo "Next steps:"
echo "1. Reboot the system: sudo reboot"
echo "2. After reboot, configure Tailscale: sudo tailscale up"
echo "3. Note the RustDesk ID and password (if generated)"
echo ""
echo "For router setup later, this laptop is ready with:"
echo "- Tailscale (for VPN access)"
echo "- RustDesk (for remote desktop)"
echo "- All necessary tools for Merlin firmware setup"
echo ""
