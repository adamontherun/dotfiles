#!/usr/bin/env zsh
set -e

dotfiledir="$(cd "$(dirname "$0")" && pwd)"

if [ -x "/opt/homebrew/bin/brew" ] && [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

VSCODE_USER_SETTINGS_DIR="${HOME}/Library/Application Support/Code/User"

if [ -d "$VSCODE_USER_SETTINGS_DIR" ]; then
    ln -sf "${dotfiledir}/settings/VSCode-Settings.json" "${VSCODE_USER_SETTINGS_DIR}/settings.json"
    ln -sf "${dotfiledir}/settings/VSCode-Keybindings.json" "${VSCODE_USER_SETTINGS_DIR}/keybindings.json"
    echo "VS Code settings and keybindings have been updated."
else
    echo "VS Code user settings directory does not exist. Please ensure VS Code is installed."
fi

code .
echo "Login to extensions (Copilot, Grammarly, etc) within VS Code."
echo "Press enter to continue..."
read -r
