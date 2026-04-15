#!/bin/bash
# macOS system defaults — sensible settings for a dev machine
# Run via: deploy-dotfiles-local --macos-defaults
# Or manually: ~/.dotfiles/macos-defaults.sh
#
# Note: most settings take effect immediately; some require a logout/restart.

set -euo pipefail

echo "Applying macOS defaults..."

# ── Keyboard ──────────────────────────────────────────────────────────────────
echo "  Keyboard..."

# Fast key repeat (lower = faster; default KeyRepeat=6, InitialKeyRepeat=25)
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable press-and-hold accent menu — enables key repeat for all keys
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Disable auto-correct and smart punctuation (annoying in terminals / code)
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Full keyboard access for all controls (Tab through buttons, not just text fields)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# ── Trackpad ──────────────────────────────────────────────────────────────────
echo "  Trackpad..."

# Tap to click (for this user and the login screen)
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# ── Finder ────────────────────────────────────────────────────────────────────
echo "  Finder..."

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show path bar and status bar
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# Use list view by default (Nlsv=list, icnv=icons, clmv=columns, glyv=gallery)
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Default to home folder when opening a new Finder window
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"

# Keep folders on top when sorting
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# No warning when changing file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Don't create .DS_Store on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Disable disk image verification (faster mounting)
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true

# ── Dock ──────────────────────────────────────────────────────────────────────
echo "  Dock..."

# Auto-hide
defaults write com.apple.dock autohide -bool true

# Remove auto-hide delay and shorten animation
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.2

# Don't show recent apps in Dock
defaults write com.apple.dock show-recents -bool false

# Smaller icon size
defaults write com.apple.dock tilesize -int 48

# Minimize windows into application icon
defaults write com.apple.dock minimize-to-application -bool true

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# ── Screenshots ───────────────────────────────────────────────────────────────
echo "  Screenshots..."

mkdir -p "$HOME/Desktop/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Desktop/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true   # no drop shadow

# ── Activity Monitor ──────────────────────────────────────────────────────────
defaults write com.apple.ActivityMonitor ShowCategory -int 0       # show all processes
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

# ── TextEdit ──────────────────────────────────────────────────────────────────
defaults write com.apple.TextEdit RichText -int 0                  # default to plain text
defaults write com.apple.TextEdit PlainTextEncoding -int 4         # UTF-8
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# ── Restart affected apps ─────────────────────────────────────────────────────
echo "  Restarting Finder and Dock..."
killall Finder     2>/dev/null || true
killall Dock       2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo ""
echo "Done. Some settings (keyboard, trackpad) require a logout/restart to take full effect."
