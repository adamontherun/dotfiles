# Set PATHS
if [ -x "/opt/homebrew/bin/brew" ]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

export PATH="$HOME/.local/bin:$PATH"

# Some CLI installers silently replace a managed dotfile's symlink with
# a disconnected regular file. Catch and auto-repair the safe case here.
[ -x "$HOME/dotfiles/check-symlinks.sh" ] && "$HOME/dotfiles/check-symlinks.sh" --fix --quiet
