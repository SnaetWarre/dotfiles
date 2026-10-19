#!/usr/bin/env bash
# macOS settings that match the Hyprland setup. Safe to run again.
set -euo pipefail

# Free Cmd+Space for Tinycast: turn off the Spotlight (64) and Finder search (65) shortcuts.
disable_hotkey() { # id, key char code, key code, modifier mask
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$1" \
    "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>$2</integer><integer>$3</integer><integer>$4</integer></array><key>type</key><string>standard</string></dict></dict>"
}
disable_hotkey 64 32 49 1048576     # Cmd+Space
disable_hotkey 65 65535 49 1572864  # Cmd+Option+Space
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

# Fast key repeat, and repeat instead of the accent popup (for vim).
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15
defaults write -g ApplePressAndHoldEnabled -bool false

# Trackpad: tap to click, natural scrolling (tap_to_click, natural_scroll).
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1
defaults write -g com.apple.swipescrolldirection -bool true

# Ctrl+Cmd+drag moves a window from anywhere, like Super+drag.
defaults write -g NSWindowShouldDragOnGesture -bool true
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false

# Dock out of the way; Mission Control groups windows per app (AeroSpace advice).
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock expose-group-apps -bool true

# One Space across displays, so AeroSpace handles monitors well. Needs a logout.
defaults write com.apple.spaces spans-displays -bool true

# Finder: show hidden files, extensions, path bar.
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write -g AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv

# Screenshots into ~/Pictures/Screenshots instead of the desktop.
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"

killall Dock Finder SystemUIServer 2>/dev/null || true
