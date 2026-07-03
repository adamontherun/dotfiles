# OPENSPEC:START
# OpenSpec shell completions configuration
fpath=("/Users/adamsmith/.zsh/completions" $fpath)
autoload -Uz compinit
compinit
# OPENSPEC:END

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt APPEND_HISTORY

# Useful zsh options
setopt AUTO_CD
setopt CORRECT
setopt COMPLETE_IN_WORD

# Don't ask if user is sure when running rm with wildcards (like bash)
setopt rmstarsilent

# If wildcard pattern has no matches, return an empty string (like bash)
setopt no_nomatch

# Load dotfiles:
for file in ~/.{aliases,private}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# asdf version manager (installed via Homebrew). Sourced from Homebrew's
# stable "opt" symlink (auto-updated by brew on upgrade) rather than
# $(brew --prefix asdf), which spawns the brew binary on every shell
# startup and can trigger its auto-update check.
if [ -d /opt/homebrew/opt/asdf ]; then
    . /opt/homebrew/opt/asdf/libexec/asdf.sh
fi

# Prompt
export STARSHIP_CONFIG="$HOME/dotfiles/starship.toml"
eval "$(starship init zsh)"

# Aliases
alias claudeyolo='claude --dangerously-skip-permissions'

render() {
  if [ "$1" = "logout" ]; then
    rm -f ~/.render/cli.yaml
  else
    command render "$@"
  fi
}

# Environment variables
export AWS_PROFILE=maymont-labs-dev
