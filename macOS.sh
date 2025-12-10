#!/usr/bin/env zsh
set -e

if ! xcode-select -p &>/dev/null; then
    xcode-select --install
    echo "Complete the installation of Xcode Command Line Tools before proceeding."
    echo "Press enter to continue..."
    read -r
else
    echo "Xcode Command Line Tools already installed. Skipping..."
fi

softwareupdate --install-rosetta --agree-to-license

# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Add Bluetooth to Menu Bar for battery percentages
defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true
killall ControlCenter

# Faster key repeat
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Dock settings
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.5
killall Dock

# Screenshot location
mkdir -p ~/Desktop/Screenshots
defaults write com.apple.screencapture location ~/Desktop/Screenshots

# Disable "natural" scroll direction
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
