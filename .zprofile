# Set PATHS
if [ -x "/opt/homebrew/bin/brew" ]; then
    # For Apple Silicon Macs
    export PATH="/opt/homebrew/bin:$PATH"
fi

export PATH="$HOME/.local/bin:$PATH"
