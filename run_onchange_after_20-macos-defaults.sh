#!/bin/sh
# macOS system preferences.
#
# run_onchange_: chezmoi re-runs this only when the file itself changes, so it
# is not paid on every apply. run_*_after_: it runs after files are written.
#
# Every value here was read off this machine with `defaults read` rather than
# copied from a list, so applying it reproduces the settings actually in use
# rather than someone else's taste. Anything left at the macOS default is
# deliberately absent: writing a value identical to the default just adds a key
# to be maintained.
#
# To capture a new setting: change it in System Settings, find the key with
#   defaults read > /tmp/before && <change it> && defaults read > /tmp/after
#   diff /tmp/before /tmp/after
# then add the corresponding `defaults write` line here.
#
# Verify with `defaults read <domain> <key>`; revert any single line with
# `defaults delete <domain> <key>`.

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

# --- finder -----------------------------------------------------------------

defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Column view. Options: icnv (icon), Nlsv (list), clmv (column), glyv (gallery).
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
defaults write com.apple.finder ShowPathbar -bool true

# --- dock -------------------------------------------------------------------

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 55

# --- settings not previously configured -------------------------------------
# These were at macOS defaults on this machine. They are grouped separately so
# it stays obvious which lines reproduce the existing setup and which change it.

# Keep .DS_Store off network shares and USB volumes, so they stop turning up in
# repositories and on other people's drives.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Screenshots as PNG into a dedicated folder rather than scattered on the
# desktop, and without the drop shadow around window captures.
mkdir -p "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# Show the full POSIX path in the Finder title bar, which makes it obvious
# which of several similarly-named directories is open.
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Search the current folder by default instead of the whole Mac.
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Skip the "are you sure you want to open this" prompt for apps already
# downloaded and verified.
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Do not create .DS_Store-style metadata prompts when changing a file extension.
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# --- apply ------------------------------------------------------------------
# Most of the above needs the owning process restarted to take effect. Finder
# and Dock restart transparently; the keyboard settings apply to newly launched
# applications, so a logout is needed for them to reach everything.

for app in Finder Dock; do
	killall "$app" >/dev/null 2>&1 || true
done

echo "==> macOS defaults applied"
echo "    Keyboard changes reach already-running apps only after a logout."
