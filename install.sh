#!/usr/bin/env bash

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
    eval $@
}

echo ""
headline " Let's secure your Mac and install basic applications."
echo ""
echo "Modifying settings for user: $user."
# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

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

echo "Save screenshots in PNG format."
run defaults write com.apple.screencapture type -string png

echo "Save screenshots to user screenshots directory instead of desktop."
run mkdir ~/Pictures/Screenshots
run defaults write com.apple.screencapture location -string ~/Pictures/Screenshots

echo "Disable menu transparency."
run defaults write com.apple.universalaccess reduceTransparency -int 1

echo "Disable mouse enlargement with jiggle."
run defaults write ~/Library/Preferences/.GlobalPreferences CGDisableCursorLocationMagnification -bool true

echo "Show all filename extensions."
run defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "Disable the warning when changing a file extension."
run defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo "Use list view in all Finder windows by default."
run defaults write com.apple.finder FXPreferredViewStyle -string '"Nlsv"'

echo "Don't write DS_Store files to network shares."
run defaults write DSDontWriteNetworkStores com.apple.desktopservices -int 1

echo "Enable development menu in Safari"
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# Security And Privacy Improvements
echo "Disable Safari from auto-filling sensitive data."
run defaults write ~/Library/Preferences/com.apple.Safari AutoFillCreditCardData -bool false
run defaults write ~/Library/Preferences/com.apple.Safari AutoFillFromAddressBook -bool false
run defaults write ~/Library/Preferences/com.apple.Safari AutoFillMiscellaneousForms -bool false

echo "Disable Safari from automatically opening files."
run defaults write ~/Library/Preferences/com.apple.Safari AutoOpenSafeDownloads -bool false

echo "Always block cookies and local storage in Safari."
run defaults write ~/Library/Preferences/com.apple.Safari BlockStoragePolicy -bool false

echo "Enable Safari warnings when visiting fradulent websites."
run defaults write ~/Library/Preferences/com.apple.Safari WarnAboutFraudulentWebsites -bool true

echo "Block popups in Safari."
run defaults write ~/Library/Preferences/com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false
run defaults write ~/Library/Preferences/com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false

echo "Safari should treat SHA-1 certificates as insecure."
run defaults write ~/Library/Preferences/com.apple.Safari TreatSHA1CertificatesAsInsecure -bool true

echo "Disable pre-loading websites with high search rankings."
run defaults write ~/Library/Preferences/com.apple.Safari PreloadTopHit -bool false

echo "Enable Do-Not-Track HTTP header in Safari."
run defaults write ~/Library/Preferences/com.apple.Safari SendDoNotTrackHTTPHeader -bool true

echo "Disable pdf viewing in Safari."
run defaults write ~/Library/Preferences/com.apple.Safari WebKitOmitPDFSupport -bool true

echo "Disable loading remote content in emails in Apple Mail."
run defaults write ~/Library/Preferences/com.apple.mail-shared DisableURLLoading -bool true

echo "Send junk mail to the junk mail box in Apple Mail."
run defaults write ~/Library/Containers/com.apple.mail/Data/Library/Preferences/com.apple.mail JunkMailBehavior -int 2

echo "Disable Captive Portal Hijacking Attack."
run defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control Active -bool false

echo "Set screen to lock as soon as the screensaver starts."
run defaults write com.apple.screensaver askForPassword -int 1
run defaults write com.apple.screensaver askForPasswordDelay -int 0

echo "Disable crash reporter."
run defaults write com.apple.CrashReporter DialogType none

echo "Enable Stealth Mode. Computer will not respond to ICMP ping requests or connection attempts from a closed TCP/UDP port."
run defaults write /Library/Preferences/com.apple.alf stealthenabled -bool true

echo "Disable wake on network access."
run systemsetup -setwakeonnetworkaccess off

echo "Disable Bonjour multicast advertisements."
run defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool YES

echo "Tap to click anywhere"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

echo "Sleep in bottom right corner"
defaults write com.apple.dock wvous-br-corner -int 10
defaults write com.apple.dock wvous-br-modifier -int 0

echo "Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

echo "Kill frozen apps"
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

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

# Note: Before installing Homebrew, set the following settings in your .bash_profile for increased privacy.
# export HOMEBREW_NO_ANALYTICS=1
# export HOMEBREW_NO_INSECURE_REDIRECT=1
echo "Install Homebrew."
which -s brew
if [[ $? != 0 ]] ; then
    run '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
else
    run brew update
fi

echo '🛠  Installing Homebrew packages…'
brew bundle

echo '🛠  Installing dotfiles…'
rcup

# Install all the Mac App Store applications using mas. https://github.com/mas-cli/mas
mac_app_login=$(mas account | grep @)
if [ -z "$mac_app_login" ] ; then
    chapter "Let's install Mac App Store applications. What is your Mac App Store email login? $bold"
    read mac_app_login
    run mas signin $mac_app_login
fi

echo "Install Reeder."
run mas install 880001334

echo "Install Keynote."
run mas install 409183694

echo "Install Things3."
run mas install 904280696

echo "Install Slack."
run mas install 803453959

# echo "Install Telegram."
# run mas install 803453959
#TODO: add apps

echo "Upgrade any Mac App Store applications."
run mas upgrade

echo "Run one final check to make sure software is up to date."
run softwareupdate -i -a

run killall Dock
run killall Finder
run killall SystemUIServer

chapter "Some settings will not take effect until you restart your computer."
headline " Your Mac is setup and ready!"