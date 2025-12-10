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
