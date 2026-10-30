# Some installers replace this symlink with a regular file, which silently
# disconnects it from the repo.
[[ -L ~/.zshrc ]] || print -u2 "warning: ~/.zshrc is not a symlink. Run ~/dotfiles/install.sh --links"

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# Shell options
setopt AUTO_CD COMPLETE_IN_WORD

# Completion. `brew shellenv` in .zprofile puts Homebrew's completions on fpath.
autoload -Uz compinit
compinit

# Aliases and untracked secrets
source ~/.aliases
[[ -r ~/.private ]] && source ~/.private

# Tools
eval "$(mise activate zsh)"
eval "$(starship init zsh)"
source <(fzf --zsh)
