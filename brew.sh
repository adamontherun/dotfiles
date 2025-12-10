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

# Update Homebrew and Upgrade any already-installed formulae
brew update
brew upgrade
brew upgrade --cask
brew cleanup

# Add the HashiCorp tap if not already added
if ! brew tap | grep -q "^hashicorp/tap$"; then
    echo "Tapping HashiCorp repository..."
    brew tap hashicorp/tap
else
    echo "HashiCorp repository is already tapped. Skipping..."
fi

# Define an array of packages to install using Homebrew.
packages=(
    "asdf"
    "bash"
    "zsh"
    "git"
    "tree"
    "pylint"
    "black"
    "hashicorp/tap/terraform"
    "git-lfs"
    "postgresql@16"
    "mysql"
    "redis"
    "dart-sdk"
    "awscli"
    "coreutils"
    "curl"
    "wget"
    "pngquant"
    "jpegoptim"
    "svgo"
    "optipng"
    "poetry"
    "composer"
    "uv"
    "libyaml"
)

# Loop over the array to install each application.
for package in "${packages[@]}"; do
    if brew list --formula | grep -q "^$package\$"; then
        echo "$package is already installed. Skipping..."
    else
        echo "Installing $package..."
        brew install "$package" || echo "Warning: Failed to install $package. Continuing..."
    fi
done

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


# Define an array of applications to install using Homebrew Cask.
apps=(
    "android-studio"
    "charles"
    "db-browser-for-sqlite"
    "dbeaver-community"
    "discord"
    "docker"
    "dotnet-sdk"
    "flutter"
    "github"
    "google-chrome"
    "granola"
    "microsoft-teams"
    "neo4j"
    "ngrok"
    "notion"
    "obs"
    "postman"
    "react-native-debugger"
    "tableplus"
    "virtualbox"
    "visual-studio-code"
    "zoom"
)

# Loop over the array to install each application.
for app in "${apps[@]}"; do
    if brew list --cask | grep -q "^$app\$"; then
        echo "$app is already installed. Skipping..."
    else
        echo "Installing $app..."
        brew install --cask "$app" || echo "Warning: Failed to install $app. Continuing..."
    fi
done

fonts=(
    "font-source-code-pro"
    "font-lato"
    "font-montserrat"
    "font-nunito"
    "font-open-sans"
    "font-oswald"
    "font-poppins"
    "font-raleway"
    "font-roboto"
)

for font in "${fonts[@]}"; do
    # Check if the font is already installed
    if brew list --cask | grep -q "^$font\$"; then
        echo "$font is already installed. Skipping..."
    else
        echo "Installing $font..."
        brew install --cask "$font" || echo "Warning: Failed to install $font. Continuing..."
    fi
done

# Once fonts are installed, import your Terminal Profile
echo "Import your terminal settings..."
echo "Terminal -> Settings -> Profiles -> Import..."
echo "Import from ${dotfiledir}/settings/CMS.terminal"
play_notification
echo "Press enter to continue..."
read -r

# Update and clean up again for safe measure
brew update
brew upgrade
brew upgrade --cask
brew cleanup

echo "Please sign in to your apps:"
echo "- Google Chrome"
echo "- Connect Google Account (System Settings -> Internet Accounts)"
echo "- Discord"
play_notification
echo "Press enter when finished..."
read -r

# Add asdf plugins
asdf plugin add python || true
asdf plugin add nodejs || true
asdf plugin add ruby || true

# Install latest versions
asdf install python latest || echo "Warning: Failed to install Python. Continuing..."
asdf install nodejs latest || echo "Warning: Failed to install Node.js. Continuing..."
asdf install ruby latest || echo "Warning: Failed to install Ruby. Continuing..."

# Set global versions (only if installed)
asdf global python latest 2>/dev/null || true
asdf global nodejs latest 2>/dev/null || true
asdf global ruby latest 2>/dev/null || true

# Install Prettier (requires Node.js from asdf)
npm install --global prettier || echo "Warning: Failed to install Prettier. Continuing..."

# Install Claude Code (requires Node.js from asdf)
npm install --global @anthropic-ai/claude-code || echo "Warning: Failed to install Claude Code. Continuing..."

# Install Cocoapods
echo "Installing Cocoapods..."
gem install cocoapods --user-install || echo "Warning: Failed to install Cocoapods. Continuing..."

# Verify installation
if ! command -v pod &>/dev/null; then
    echo "Warning: Cocoapods not available. You may need to install Ruby first."
else
    echo "Cocoapods installed successfully."
fi
