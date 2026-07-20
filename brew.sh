#!/usr/bin/env zsh
set -e

play_notification() {
    afplay /System/Library/Sounds/Glass.aiff 2>/dev/null || true
}

dotfiledir="$(cd "$(dirname "$0")" && pwd)"

# Install Homebrew if it isn't already installed
if ! command -v brew &>/dev/null; then
    echo "Homebrew not installed. Installing Homebrew."
    play_notification
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Attempt to set up Homebrew PATH automatically for this session
    if [ -x "/opt/homebrew/bin/brew" ]; then
        # For Apple Silicon Macs
        echo "Configuring Homebrew in PATH for Apple Silicon Mac..."
        export PATH="/opt/homebrew/bin:$PATH"
    fi
else
    echo "Homebrew is already installed."
fi

# Verify brew is now accessible
if ! command -v brew &>/dev/null; then
    echo "Failed to configure Homebrew in PATH. Please add Homebrew to your PATH manually."
    exit 1
fi

# Install everything listed in Brewfile (taps, formulae, casks, VS Code
# extensions, npm/uv globals). Regenerate this file with:
#   brew bundle dump --file=Brewfile --force
brew update
brew bundle install --file="${dotfiledir}/Brewfile" || echo "Warning: Some Brewfile dependencies failed to install. Continuing..."
brew cleanup

# Get the path to Homebrew's zsh
BREW_ZSH="$(brew --prefix)/bin/zsh"
# Check if Homebrew's zsh is already the default shell
if [ "$SHELL" != "$BREW_ZSH" ]; then
    echo "Changing default shell to Homebrew zsh"
    # Check if Homebrew's zsh is already in allowed shells
    if ! grep -Fxq "$BREW_ZSH" /etc/shells; then
        echo "Adding Homebrew zsh to allowed shells"
        play_notification
        echo "$BREW_ZSH" | sudo tee -a /etc/shells >/dev/null
    fi
    # Set the Homebrew zsh as default shell
    play_notification
    chsh -s "$BREW_ZSH"
    echo "Default shell changed to Homebrew zsh."
else
    echo "Homebrew zsh is already the default shell. Skipping configuration."
fi

# Git config name
current_name=$($(brew --prefix)/bin/git config --global --get user.name 2>/dev/null || echo "")
if [ -z "$current_name" ]; then
    play_notification
    echo "Please enter your FULL NAME for Git configuration:"
    read -r git_user_name
    $(brew --prefix)/bin/git config --global user.name "$git_user_name"
    echo "Git user.name has been set to $git_user_name"
else
    echo "Git user.name is already set to '$current_name'. Skipping configuration."
fi

# Git config email
current_email=$($(brew --prefix)/bin/git config --global --get user.email 2>/dev/null || echo "")
if [ -z "$current_email" ]; then
    play_notification
    echo "Please enter your EMAIL for Git configuration:"
    read -r git_user_email
    $(brew --prefix)/bin/git config --global user.email "$git_user_email"
    echo "Git user.email has been set to $git_user_email"
else
    echo "Git user.email is already set to '$current_email'. Skipping configuration."
fi

# Git global defaults
$(brew --prefix)/bin/git config --global init.defaultBranch main
$(brew --prefix)/bin/git config --global pull.rebase false
$(brew --prefix)/bin/git config --global core.editor "code --wait"

# SSH key generation
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "Generating SSH key for GitHub..."
    ssh-keygen -t ed25519 -C "$current_email" -f ~/.ssh/id_ed25519 -N ""
    echo "SSH key generated at ~/.ssh/id_ed25519"
    echo "Add this public key to GitHub:"
    cat ~/.ssh/id_ed25519.pub
    echo ""
    play_notification
    echo "Press enter to continue..."
    read -r
else
    echo "SSH key already exists. Skipping generation."
fi

# Install Prettier, which I use in VS Code
$(brew --prefix)/bin/npm install --global prettier || echo "Warning: Failed to install Prettier. Continuing..."

# Install Cocoapods
echo "Installing Cocoapods..."
gem install cocoapods --user-install || echo "Warning: Failed to install Cocoapods. Continuing..."

# Verify installation
if ! command -v pod &>/dev/null; then
    echo "Warning: Cocoapods not available. You may need to install Ruby first."
else
    echo "Cocoapods installed successfully."
fi
