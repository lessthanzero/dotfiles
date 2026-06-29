#!/usr/bin/env bash
# Fedora Kinoite / Silverblue: full dev bootstrap.
# Packages (rpm-ostree & flatpak) + Homebrew (mise, uv, just, direnv) + OMZ & p10k + Ollama/Open WebUI.
# suitable for eventually converting the machine into a headless infrastructure node.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Verifying platform compatibility..."
if [ ! -f /etc/os-release ] || ! grep -qiE 'fedora|kinoite|silverblue|sericea' /etc/os-release; then
    echo "ERROR: This script is intended for Fedora Kinoite / Silverblue (Atomic Desktop)." >&2
    exit 1
fi

# Ask for sudo upfront if needed
if ! sudo -n true 2>/dev/null; then
    echo "==> Some commands require administrative privileges. Please authenticate:"
    sudo -v
fi

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "==> Enabling RPM Fusion repositories..."
if [ ! -f /etc/yum.repos.d/rpmfusion-free.repo ]; then
    sudo rpm-ostree install --apply-live -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm || \
    sudo rpm-ostree install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
else
    echo "RPM Fusion is already enabled."
fi

echo "==> Enabling Flathub repository..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "==> Installing rpm-ostree package overlays..."
to_install=()
while read -r pkg; do
    # Skip comments and empty lines
    [[ "$pkg" =~ ^# ]] || [[ -z "$pkg" ]] && continue
    if ! rpm -q "$pkg" &>/dev/null; then
        to_install+=("$pkg")
    fi
done < "${SCRIPT_DIR}/packages/rpm-ostree.txt"

if [ ${#to_install[@]} -gt 0 ]; then
    echo "Installing: ${to_install[*]}..."
    sudo rpm-ostree install --apply-live -y "${to_install[@]}" || \
    sudo rpm-ostree install -y "${to_install[@]}"
    echo "NOTE: Some overlays require a reboot to be fully active."
else
    echo "All rpm-ostree packages are already layered."
fi

echo "==> Installing Flatpaks..."
while read -r app; do
    [[ "$app" =~ ^# ]] || [[ -z "$app" ]] && continue
    echo "Flatpak: $app..."
    flatpak install --or-update -y flathub "$app"
done < "${SCRIPT_DIR}/packages/flatpaks.txt"

echo "==> Setting up Homebrew..."
if [ ! -d "/home/linuxbrew/.linuxbrew" ]; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Load Homebrew environment for this session
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

echo "==> Installing Homebrew developer packages..."
brew install mise uv just direnv

echo "==> Configuring automatic updates..."
# Configure rpm-ostreed automatic updates (stage on check)
if [ -f /etc/rpm-ostreed.conf ]; then
    if ! grep -q "AutomaticUpdatePolicy=stage" /etc/rpm-ostreed.conf; then
        sudo sed -i 's/#AutomaticUpdatePolicy=none/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf
        sudo sed -i 's/AutomaticUpdatePolicy=none/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf
    fi
fi
sudo systemctl enable --now rpm-ostreed-automatic.timer

# Create systemd user timer for Flatpak auto-updates
mkdir -p ~/.config/systemd/user
cat << 'EOF' > ~/.config/systemd/user/flatpak-update.service
[Unit]
Description=Update Flatpaks
Documentation=man:flatpak(1)

[Service]
Type=oneshot
ExecStart=/usr/bin/flatpak update -y
EOF

cat << 'EOF' > ~/.config/systemd/user/flatpak-update.timer
[Unit]
Description=Update Flatpaks Daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now flatpak-update.timer

echo "==> Running firmware update check..."
if command -v fwupdmgr &>/dev/null; then
    sudo fwupdmgr refresh || true
    fwupdmgr get-updates || true
fi

echo "==> Configuring system services (SSH & Tailscale)..."
sudo systemctl enable --now sshd
sudo systemctl enable --now tailscaled

echo "==> Enabling user session lingering (allows headless user containers)..."
sudo loginctl enable-linger "$USER"

echo "==> Setting up host Ollama service..."
mkdir -p ~/.local/bin
if [ ! -f ~/.local/bin/ollama ]; then
    curl -L https://ollama.com/download/ollama-linux-amd64 -o ~/.local/bin/ollama
    chmod +x ~/.local/bin/ollama
fi

cat << 'EOF' > ~/.config/systemd/user/ollama.service
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=%h/.local/bin/ollama serve
User=%u
Restart=always
RestartSec=3
Environment="OLLAMA_HOST=0.0.0.0"

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now ollama.service

echo "==> Setting up Open WebUI container (Podman)..."
cat << 'EOF' > ~/.config/systemd/user/open-webui.service
[Unit]
Description=Open WebUI Container
After=ollama.service

[Service]
Restart=always
ExecStartPre=-/usr/bin/podman stop open-webui
ExecStartPre=-/usr/bin/podman rm open-webui
ExecStart=/usr/bin/podman run \
    --name open-webui \
    -p 3000:8080 \
    -e OLLAMA_BASE_URL=http://host.containers.internal:11434 \
    --add-host=host.containers.internal:host-gateway \
    -v open-webui:/app/backend/data \
    ghcr.io/open-webui/open-webui:main
ExecStop=/usr/bin/podman stop open-webui

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now open-webui.service

echo "==> Setting up Oh My Zsh + Powerlevel10k..."
bash "${SCRIPT_DIR}/../scripts/install-omz-p10k.sh"

echo "==> Applying chezmoi dotfiles..."
if command -v chezmoi &>/dev/null; then
    chezmoi apply --force
elif [ -f ~/.local/bin/chezmoi ]; then
    ~/.local/bin/chezmoi apply --force
else
    echo "Warning: chezmoi not found. Please install chezmoi and run 'chezmoi apply' manually."
fi

echo ""
echo "============================================="
echo "Fedora Kinoite bootstrap completed!"
echo "Next steps:"
echo "  1. If any packages were layered, reboot the system."
echo "  2. Run 'sudo tailscale up' to connect to your Tailnet."
echo "  3. Verify services using: bash fedora-kinoite/verify.sh"
echo "  4. Access Open WebUI at http://localhost:3000"
echo "============================================="
