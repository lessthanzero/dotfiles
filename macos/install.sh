#!/usr/bin/env bash

# Error handling
set -euo pipefail

# Current User
user=$(id -un)

# Script's color palette
reset="\033[0m"
highlight="\033[42m\033[97m"
dot="\033[33m▸ $reset"
dim="\033[2m"
bold="\033[1m"

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

headline() {
    printf "${highlight} %s ${reset}\n" "$@"
}

chapter() {
    echo "${highlight} $((count++)).) $@ ${reset}\n"
}

# Prints out a step, if last parameter is true then without an ending newline
step() {
    if [ $# -eq 1 ]
    then echo "${dot}$@"
    else echo "${dot}$@"
    fi
}

run() {
    echo "${dim}▹ $@ $reset"
    # Use eval for tilde expansion and variable substitution, but with proper quoting
    eval "$@"
}

echo ""
headline " Let's secure your Mac and install basic applications."
echo ""
echo "Modifying settings for user: $user."
# Close any open System Preferences/Settings panes, to prevent them from overriding
# settings we're about to change
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || \
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

# Ask for the administrator password upfront
if [ $(sudo -n uptime 2>&1|grep "load"|wc -l) -eq 0 ]
then
    step "Some of these settings are system-wide, therefore we need your permission."
    sudo -v
    echo ""
fi

echo "Use 24-hour time. Use the format EEE MMM d  H:mm:ss"
run defaults write com.apple.menuextra.clock DateFormat -string 'EEE MMM d  H:mm:ss'

echo "Disable press-and-hold for keys in favor of key repeat."
run defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

echo "Set a fast keyboard repeat rate, after a good initial delay."
run defaults write NSGlobalDomain KeyRepeat -int 1
run defaults write NSGlobalDomain InitialKeyRepeat -int 25

echo "Disable auto-correct."
run defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

echo "Speed up mission control animations."
run defaults write com.apple.dock expose-animation-duration -float 0.3

echo "Automatically hide and show the Dock."
run defaults write com.apple.dock autohide -bool true

echo "Minimize apps to Dock icon"
run defaults write com.apple.dock minimize-to-application -bool true

echo "Save screenshots in PNG format."
run defaults write com.apple.screencapture type -string png

echo "Save screenshots to user screenshots directory instead of desktop."
run mkdir ~/Pictures/Screenshots
run defaults write com.apple.screencapture location -string ~/Pictures/Screenshots

echo "Disable mouse enlargement with jiggle."
run defaults write ~/Library/Preferences/.GlobalPreferences CGDisableCursorLocationMagnification -bool true

echo "Set the Finder prefs for showing a few different volumes on the Desktop."
run defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
run defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

echo "Disable the warning when changing a file extension."
run defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo "Use list view in all Finder windows by default."
run defaults write com.apple.finder FXPreferredViewStyle -string '"Nlsv"'

echo "Don't write DS_Store files to network shares."
run defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

echo "Enable development menu in Safari"
run defaults write com.apple.Safari IncludeDevelopMenu -bool true
run defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
run defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

echo "Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in Mail.app"
run defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# Security And Privacy Improvements
echo "Disable Safari from auto-filling sensitive data."
run defaults write ~/Library/Preferences/com.apple.Safari AutoFillCreditCardData -bool false
run defaults write ~/Library/Preferences/com.apple.Safari AutoFillFromAddressBook -bool false
run defaults write ~/Library/Preferences/com.apple.Safari AutoFillMiscellaneousForms -bool false

echo "Disable Safari from automatically opening files."
run defaults write ~/Library/Preferences/com.apple.Safari AutoOpenSafeDownloads -bool false

echo "Enable Safari warnings when visiting fradulent websites."
run defaults write ~/Library/Preferences/com.apple.Safari WarnAboutFraudulentWebsites -bool true

echo "Block popups in Safari."
run defaults write ~/Library/Preferences/com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false
run defaults write ~/Library/Preferences/com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false

echo "Safari should treat SHA-1 certificates as insecure."
run defaults write ~/Library/Preferences/com.apple.Safari TreatSHA1CertificatesAsInsecure -bool true

echo "Disable pre-loading websites with high search rankings."
run defaults write ~/Library/Preferences/com.apple.Safari PreloadTopHit -bool false

echo "Disable pdf viewing in Safari."
run defaults write ~/Library/Preferences/com.apple.Safari WebKitOmitPDFSupport -bool true

echo "Hide Safari's bookmark bar."
run defaults write com.apple.Safari ShowFavoritesBar -bool false

echo "Disable loading remote content in emails in Apple Mail."
run defaults write ~/Library/Preferences/com.apple.mail-shared DisableURLLoading -bool true

echo "Send junk mail to the junk mail box in Apple Mail."
run defaults write ~/Library/Containers/com.apple.mail/Data/Library/Preferences/com.apple.mail JunkMailBehavior -int 2

echo "Display most recent messages on top"
run defaults write com.apple.mail ConversationViewSortDescending -bool true

echo "Disable Captive Portal Hijacking Attack."
run defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control Active -bool false

echo "Disable crash reporter."
run defaults write com.apple.CrashReporter DialogType none

echo "Enable Stealth Mode. Computer will not respond to ICMP ping requests or connection attempts from a closed TCP/UDP port."
run defaults write /Library/Preferences/com.apple.alf stealthenabled -bool true

echo "Disable wake on network access."
run systemsetup -setwakeonnetworkaccess off

echo "Disable Bonjour multicast advertisements."
run defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool YES

echo "Tap to click anywhere"
run defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
run defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
run defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

echo "Automatically quit printer app once the print jobs complete"
run defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

echo "Expand save panel by default."
run defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
run defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

echo "Expand print panel by default."
run defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
run defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

echo "Keep folders on top when sorting by name."
run defaults write com.apple.finder _FXSortFoldersFirst -bool true

echo "Kill frozen apps"
run defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

echo "Prevent Photos from opening automatically when devices are plugged in"
run defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

# This is disabled by default, but sometimes people turn it on and forget to turn it back off again.
echo "Turn off remote desktop access."
run sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -configure -access -off

echo "Enable Mac App Store automatic updates."
run defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

echo "Check for Mac App Store updates daily."
run defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

echo "Download Mac App Store updates in the background."
run defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

echo "Install Mac App Store system data files & security updates."
run defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

echo "Turn on Mac App Store auto-update."
run defaults write com.apple.commerce AutoUpdate -bool true

# Install Applications

# Set Homebrew privacy settings before installation
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSECURE_REDIRECT=1

echo "Install Homebrew."
if ! command -v brew &> /dev/null; then
    # Modern Homebrew installation
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    run brew update
fi

echo '🛠  Installing Homebrew packages…'
run brew bundle

# Install VS Code extensions if code command is available
if command -v code &> /dev/null; then
    echo "Install Visual Studio Code Extensions."
    vscode_install_ext(){
        run code --install-extension "$@"
    }
    vscode_install_ext wesbos.theme-cobalt2
    vscode_install_ext formulahendry.auto-close-tag
    vscode_install_ext dbaeumer.vscode-eslint
    vscode_install_ext eamodio.gitlens
    vscode_install_ext xabikos.javascriptsnippets
    vscode_install_ext davidanson.vscode-markdownlint
    vscode_install_ext eg2.vscode-npm-script
    vscode_install_ext christian-kohler.npm-intellisense
    vscode_install_ext esbenp.prettier-vscode
    vscode_install_ext zhouronghui.propertylist
    vscode_install_ext xabikos.reactsnippets
    vscode_install_ext qinjia.seti-icons
    # Note: code-settings-sync is deprecated, VS Code now has built-in Settings Sync
    vscode_install_ext ms-vscode.sublime-keybindings
    vscode_install_ext ms-vsliveshare.vsliveshare
else
    echo "Warning: VS Code 'code' command not found. Install VS Code first or add to PATH."
fi

# Install dotfiles if rcm is available (chezmoi users: run `chezmoi apply` yourself; do not rely on rcup alone)
if command -v rcup &> /dev/null; then
    echo '🛠  Installing dotfiles…'
    rcup
else
    echo "Warning: rcm not installed, skipping dotfiles installation"
fi

# Install all the Mac App Store applications using mas. https://github.com/mas-cli/mas
if command -v mas &> /dev/null; then
    mac_app_login=$(mas account 2>/dev/null | grep @ || true)
    if [ -z "$mac_app_login" ] ; then
        chapter "Let's install Mac App Store applications. Please sign in to the Mac App Store."
        run mas signin
    fi
else
    echo "Warning: mas-cli not installed, skipping Mac App Store applications"
fi

if command -v mas &> /dev/null; then
    echo "Installing Mac App Store applications..."
    
    # Productivity & Task Management
    echo "Install Things."
    run mas install 904280696
    
    echo "Install Deliveries."
    run mas install 924726344
    
    # Communication
    echo "Install Slack."
    run mas install 803453959
    
    echo "Install Telegram."
    run mas install 747648890
    
    # Design & Media
    echo "Install Pixelmator Pro."
    run mas install 1289583905
    
    echo "Install Affinity Designer."
    run mas install 824171161
    
    echo "Install Darkroom."
    run mas install 953286746
    
    echo "Install Droplr."
    run mas install 498672703
    
    # Security & Utilities
    echo "Install 1Password."
    run mas install 443987910
    
    echo "Install 1Password for Safari."
    run mas install 1569813296
    
    echo "Install HomePass."
    run mas install 1330266650
    
    # Development
    echo "Install Xcode."
    run mas install 497799835
    
    echo "Install Playgrounds."
    run mas install 1496833156
    
    # System & Reference
    echo "Install Mactracker."
    run mas install 430255202
    
    echo "Install Apple Configurator 2."
    run mas install 1037126344
    
    # Media & Entertainment
    echo "Install GarageBand."
    run mas install 682658836
    
    # Reading & News
    echo "Install Reeder."
    run mas install 1449412482
    
    # Safari Extensions
    echo "Install Grammarly for Safari."
    run mas install 1462114288
    
    echo "Upgrade any Mac App Store applications."
    run mas upgrade
fi

echo "Run one final check to make sure software is up to date."
run softwareupdate -i -a

run killall Dock
run killall Finder
run killall SystemUIServer

chapter "Some settings will not take effect until you restart your computer."
headline " Your Mac is setup and ready!"