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

# Language toolchains. asdf was removed 2026-07-20: its shims sat first on
# PATH and silently shadowed real binaries (it pinned Claude Code to a stale
# npm copy and broke uv outright), and no project here used .tool-versions,
# so per-project switching bought nothing. One tool per language instead:
#   python -> uv          (uv python install / uv venv / uv tool install)
#   node   -> Homebrew    (brew install node; node@20 for a fallback)
#   ruby   -> Homebrew    (brew install ruby)
#   rust   -> rustup      (keg-only, hence the PATH entry below)
# If per-project node versions are ever needed, use fnm or volta, not asdf.
if [ -d /opt/homebrew/opt/rustup/bin ]; then
    export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
fi

# Prompt
export STARSHIP_CONFIG="$HOME/dotfiles/starship.toml"
eval "$(starship init zsh)"

# Aliases
# (claudeyolo removed 2026-07-20 — the `claude` CLI installs were consolidated
# into the desktop app's own bundle, so there is no `claude` on PATH to alias.)

render() {
  if [ "$1" = "logout" ]; then
    rm -f ~/.render/cli.yaml
  else
    command render "$@"
  fi
}

# Environment variables
export AWS_PROFILE=maymont-labs-dev

# ============================================================
# PATH hygiene — keep this LAST, after everything that edits PATH.
# `typeset -U` keeps entries unique (nested shells re-run this file and
# would otherwise stack duplicates); the (N-/) glob drops entries that
# aren't existing directories, e.g. the dead /pkg/env/global/bin and the
# literal-tilde ~/.dotnet/tools that /etc/paths.d injects and zsh never
# expands. First occurrence wins, so precedence is preserved.
# ============================================================
typeset -U path PATH
path=($^path(N-/))
export PATH
