#!/bin/sh
# macOS system preferences. Every value was read off this machine with
# `defaults read`; anything left at the macOS default is deliberately absent.
#
# To capture a new setting, diff `defaults read` before and after changing it in
# System Settings. Revert one with `defaults delete <domain> <key>`.

set -eu

[ "$(uname -s)" = "Darwin" ] || exit 0

echo "==> applying macOS defaults"

# --- keyboard ---------------------------------------------------------------

# Fast key repeat. KeyRepeat is the interval between repeats and
# InitialKeyRepeat the delay before the first one; both are in 15ms units, and
# 2/25 is faster than System Settings will let you set from the UI.
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 25

# Holding a key repeats it rather than opening the accent picker. Essential for
# any modal editor: without this, holding j in neovim shows a diacritic menu.
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# --- trackpad and mouse -----------------------------------------------------

# Scroll direction: content moves opposite to fingers ("natural" off).
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Never prefer tabs. At the default an app reuses an existing window, so under
# AeroSpace a new window lands in another workspace and macOS switches you there.
# Mitigation for https://github.com/nikitabobko/AeroSpace/discussions/1929.
defaults write NSGlobalDomain AppleWindowTabbingMode -string "manual"

# --- finder -----------------------------------------------------------------

defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Column view. Options: icnv (icon), Nlsv (list), clmv (column), glyv (gallery).
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
defaults write com.apple.finder ShowPathbar -bool true

# --- dock -------------------------------------------------------------------

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 55

# --- settings not previously configured -------------------------------------
# Grouped separately so it stays obvious which lines reproduce the existing
# setup and which change it.

# Keep .DS_Store off network shares and USB volumes.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Screenshots as PNG into a dedicated folder, without the window drop shadow.
mkdir -p "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# Full POSIX path in the Finder title bar.
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Search the current folder by default instead of the whole Mac.
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Skip the "are you sure you want to change the extension?" confirmation.
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# --- apply ------------------------------------------------------------------
# Finder and Dock restart transparently; keyboard settings only reach already
# running apps after a logout.

for app in Finder Dock; do
	killall "$app" >/dev/null 2>&1 || true
done

echo "==> macOS defaults applied"
echo "    Keyboard changes reach already-running apps only after a logout."
