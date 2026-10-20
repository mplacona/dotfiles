#!/bin/bash
# macOS preferences. Run by `./install.sh --macos`; safe to re-run.
set -euo pipefail

# Finder: hidden files stay hidden, but show every extension, the path bar and the status bar
defaults write com.apple.finder AppleShowAllFiles -bool false
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

killall Finder 2>/dev/null || true
echo "  Finder settings applied"
