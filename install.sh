#!/usr/bin/env zsh
set -e

dotfiledir="$(cd "$(dirname "$0")" && pwd)"
files=(zshrc zprofile zprompt bashrc bash_profile bash_prompt aliases private)

echo "Changing to the ${dotfiledir} directory"
cd "${dotfiledir}" || exit

# create symlinks (will overwrite old dotfiles)
for file in "${files[@]}"; do
    if [ -f "${dotfiledir}/.${file}" ]; then
        echo "Creating symlink to $file in home directory."
        ln -sf "${dotfiledir}/.${file}" "${HOME}/.${file}"
    else
        echo "Warning: ${dotfiledir}/.${file} does not exist. Skipping..."
    fi
done

# Run the MacOS Script
./macOS.sh

# Run the Homebrew Script
./brew.sh

# Run VS Code Script
./vscode.sh

echo "Installation Complete!"
