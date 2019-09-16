#!/usr/bin/env sh

echo ""
echo "#############################"
echo "# Setting global mac configs from mac.sh"
echo "#############################"
echo ""

echo "show hidden files by default"
defaults write com.apple.Finder AppleShowAllFiles -bool false

echo "Finder: show all filename extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "Show Path bar in Finder"
defaults write com.apple.finder ShowPathbar -bool true

echo "Show Status bar in Finder"
defaults write com.apple.finder ShowStatusBar -bool true

echo "Stop iTunes from responding to the keyboard media keys"
launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null