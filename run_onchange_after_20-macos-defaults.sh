#!/bin/sh
set -eu

[ "$(uname -s)" = "Darwin" ] || exit 0

echo "==> applying macOS defaults"

# keyboard

defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 25

defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# trackpad and mouse

defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Mitigates AeroSpace workspace jumps: AeroSpace discussions/1929
defaults write NSGlobalDomain AppleWindowTabbingMode -string "manual"

# finder

defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
defaults write com.apple.finder ShowPathbar -bool true

# dock

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 55


defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

mkdir -p "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# apply

for app in Finder Dock; do
	killall "$app" >/dev/null 2>&1 || true
done

echo "==> macOS defaults applied"
echo "    Keyboard changes reach already-running apps only after a logout."
