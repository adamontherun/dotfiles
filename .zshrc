[ -f ~/.aliases ] && source ~/.aliases
[ -f ~/.private ] && source ~/.private
[ -f ~/.zprompt ] && source ~/.zprompt

export PATH="$HOME/.local/bin:$PATH"

if command -v brew &>/dev/null; then
    export PATH="$(brew --prefix)/bin:$(brew --prefix)/sbin:$PATH"
fi

if [ -f ~/.asdf/asdf.sh ]; then
    source ~/.asdf/asdf.sh
fi
