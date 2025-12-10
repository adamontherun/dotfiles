autoload -Uz colors && colors
setopt PROMPT_SUBST

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt APPEND_HISTORY

autoload -Uz compinit && compinit

setopt AUTO_CD
setopt CORRECT
setopt COMPLETE_IN_WORD

setopt rmstarsilent

setopt no_nomatch

for file in ~/.{zprompt,aliases,private}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

if command -v brew &>/dev/null; then
    . $(brew --prefix asdf)/libexec/asdf.sh
fi

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
