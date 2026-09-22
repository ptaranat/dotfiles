#!/bin/sh
# macOS system preferences. run_onchange_after_: re-run only when this file
# changes, after files are written.
#
# Every value was read off this machine with `defaults read`, not copied from a
# list; anything still at the macOS default is deliberately absent. To capture
# a new one, diff `defaults read` either side of the change in System Settings.
# Revert a line with `defaults delete <domain> <key>`.

set -eu

[ "$(uname -s)" = "Darwin" ] || exit 0

echo "==> applying macOS defaults"

# --- keyboard ---------------------------------------------------------------

# Repeat interval and initial delay, in 15ms units. Faster than the UI allows.
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 25

# Repeat on hold instead of the accent picker; holding j in neovim needs this.
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# --- trackpad and mouse -----------------------------------------------------

# Scroll direction: content moves opposite to fingers ("natural" off).
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# At the default ("fullscreen") an app reuses an existing window, so under
# AeroSpace a new window lands in the workspace where the first one was created
# and macOS follows it. Mitigation only, not a fix:
# https://github.com/nikitabobko/AeroSpace/discussions/1929
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
# Grouped apart so it stays obvious which lines reproduce the existing setup.

# Keep .DS_Store off network shares and USB volumes.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# PNG into a dedicated folder, no drop shadow on window captures.
mkdir -p "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# Full POSIX path in the Finder title bar.
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Search the current folder by default instead of the whole Mac.
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Skip the "change the extension?" confirmation when renaming.
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# --- apply ------------------------------------------------------------------
# Finder and Dock restart transparently; keyboard settings only reach newly
# launched apps, so a logout is needed for those.

for app in Finder Dock; do
	killall "$app" >/dev/null 2>&1 || true
done

echo "==> macOS defaults applied"
echo "    Keyboard changes reach already-running apps only after a logout."
