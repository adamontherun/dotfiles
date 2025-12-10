[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh" ]] && source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh"

if [ -x "/opt/homebrew/bin/brew" ]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

export PATH="$HOME/.cargo/bin:$PATH"

[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh" ]] && source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh"
