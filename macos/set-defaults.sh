# Sets reasonable macOS defaults.
#
# Or, in other words, set shit how I like in macOS.
#
# The original idea (and a couple settings) were grabbed from:
#   https://github.com/mathiasbynens/dotfiles/blob/master/.macos
#
# Run ./set-defaults.sh and you'll be good to go.
#
# CREDIT: https://github.com/holman/dotfiles/blob/master/macos/set-defaults.sh

# Disable press-and-hold for keys in favor of key repeat.
defaults write -g ApplePressAndHoldEnabled -bool false

# Use AirDrop over every interface. srsly this should be a default.
defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1

# Always open everything in Finder's list view. This is important.
defaults write com.apple.Finder FXPreferredViewStyle Nlsv

# Show the ~/Library folder.
chflags nohidden ~/Library

# Set the fastest key repeat rate. 1 is the fastest allowed (default is 2, slowest is 120).
# Set KeyRepeat to the fastest allowed value (1 = fastest, higher is slower)
defaults write NSGlobalDomain KeyRepeat -int 1

# Set InitialKeyRepeat to the shortest allowed delay (10 = fastest, higher is slower)
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Set the Finder prefs for showing a few different volumes on the Desktop.
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Show hidden files in Finder.
defaults write com.apple.finder AppleShowAllFiles -bool true

# Run the screensaver if we're in the bottom-left hot corner.
defaults write com.apple.dock wvous-bl-corner -int 5
defaults write com.apple.dock wvous-bl-modifier -int 0

# Safari settings (may fail on newer macOS versions due to sandboxing)
# These settings need to be configured manually in Safari preferences on modern macOS

# Global WebKit developer extras (this one still works)
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Automatically hide and show the Dock.
defaults write com.apple.dock autohide -bool true

# Show battery percentage in the menu bar (macOS Monterey and later)
defaults write com.apple.controlcenter "NSStatusItem Visible Battery" -bool true

# Disable keyboard auto-correct (spelling correction)
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable keyboard auto-punctuation
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false