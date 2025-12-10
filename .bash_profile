if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

if [ -x "/opt/homebrew/bin/brew" ]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

[[ -f "$HOME/.aftman/env" ]] && . "$HOME/.aftman/env"
