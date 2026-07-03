#!/usr/bin/env zsh

# Install Homebrew if it isn't already installed
if ! command -v brew &>/dev/null; then
    echo "Homebrew not installed. Installing Homebrew."
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
brew bundle install --file="$(dirname "$0")/Brewfile"
brew cleanup

# Get the path to Homebrew's zsh
BREW_ZSH="$(brew --prefix)/bin/zsh"
# Check if Homebrew's zsh is already the default shell
if [ "$SHELL" != "$BREW_ZSH" ]; then
    echo "Changing default shell to Homebrew zsh"
    # Check if Homebrew's zsh is already in allowed shells
    if ! grep -Fxq "$BREW_ZSH" /etc/shells; then
        echo "Adding Homebrew zsh to allowed shells"
        echo "$BREW_ZSH" | sudo tee -a /etc/shells >/dev/null
    fi
    # Set the Homebrew zsh as default shell
    chsh -s "$BREW_ZSH"
    echo "Default shell changed to Homebrew zsh."
else
    echo "Homebrew zsh is already the default shell. Skipping configuration."
fi

# Git config name
current_name=$($(brew --prefix)/bin/git config --global --get user.name)
if [ -z "$current_name" ]; then
    echo "Please enter your FULL NAME for Git configuration:"
    read git_user_name
    $(brew --prefix)/bin/git config --global user.name "$git_user_name"
    echo "Git user.name has been set to $git_user_name"
else
    echo "Git user.name is already set to '$current_name'. Skipping configuration."
fi

# Git config email
current_email=$($(brew --prefix)/bin/git config --global --get user.email)
if [ -z "$current_email" ]; then
    echo "Please enter your EMAIL for Git configuration:"
    read git_user_email
    $(brew --prefix)/bin/git config --global user.email "$git_user_email"
    echo "Git user.email has been set to $git_user_email"
else
    echo "Git user.email is already set to '$current_email'. Skipping configuration."
fi

# Install Prettier, which I use in VS Code
$(brew --prefix)/bin/npm install --global prettier

# Add asdf plugins (versions themselves are pinned in ~/.tool-versions)
for plugin in python nodejs ruby rust; do
    asdf plugin add "$plugin" 2>/dev/null || true
done

# Install Cocoapods
echo "Installing Cocoapods..."
gem install cocoapods --user-install

# Verify installation
if ! command -v pod &>/dev/null; then
    echo "Cocoapods installation failed. Please check Ruby configuration."
    exit 1
else
    echo "Cocoapods installed successfully."
fi
