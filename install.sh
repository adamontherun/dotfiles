#!/usr/bin/env zsh
# Sets up this Mac. Safe to re-run.
#   ./install.sh          full setup
#   ./install.sh --links  only refresh the symlinks
set -eu

dotfiles=${0:A:h}
failed=()

ding() {
    afplay /System/Library/Sounds/Glass.aiff 2>/dev/null || true
}

# Symlink a repo file into place, keeping any different file already there.
link() {
    local source=$dotfiles/$1 target=$2
    mkdir -p "${target:h}"
    if [[ -f $target && ! -L $target ]] && ! cmp -s "$source" "$target"; then
        mv "$target" "$target.bak"
        echo "Backed up $target to $target.bak"
    fi
    ln -sfn "$source" "$target"
}

link_all() {
    local file cursor="$HOME/Library/Application Support/Cursor/User"

    for file in .zprofile .zshrc .aliases; do
        link "$file" ~/"$file"
    done
    for file in git/config git/ignore tmux/tmux.conf mise/config.toml starship.toml; do
        link "config/$file" ~/.config/"$file"
    done
    link cursor/settings.json "$cursor/settings.json"
    link cursor/keybindings.json "$cursor/keybindings.json"
    for file in settings.json CLAUDE.md; do
        link "claude/$file" ~/.claude/"$file"
    done

    if [[ -f $dotfiles/.private ]]; then
        chmod 600 "$dotfiles/.private"
        link .private ~/.private
    else
        echo "No .private in $dotfiles yet. Restore it, then run ./install.sh --links"
    fi

    # Without this file, `git config --global` writes to ~/.config/git/config,
    # which is tracked in this public repo.
    touch ~/.gitconfig
}

if [[ ${1:-} == --links ]]; then
    link_all
    exit
fi

"$dotfiles/macOS.sh"

# Homebrew
if [[ ! -x /opt/homebrew/bin/brew ]]; then
    ding
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# Bundle keeps going past a failed entry and exits non-zero at the end.
brew bundle install --file="$dotfiles/Brewfile" || failed+=("brew bundle")

link_all

# Git identity
for key label in user.name "Full name for git" user.email "Email for git"; do
    git config --file ~/.gitconfig --get "$key" >/dev/null && continue
    ding
    read -r "value?$label: "
    git config --file ~/.gitconfig "$key" "$value"
done

# SSH key
if [[ ! -f ~/.ssh/id_ed25519 ]]; then
    mkdir -m 700 -p ~/.ssh
    ssh-keygen -t ed25519 -C "$(git config --file ~/.gitconfig user.email)" -f ~/.ssh/id_ed25519 -N ""
    echo "Add this public key to GitHub and the mac mini:"
    cat ~/.ssh/id_ed25519.pub
    ding
    read -r "?Press enter to continue..."
fi

# Toolchains
mkdir -p ~/.terraform.d/plugin-cache
/opt/homebrew/opt/rustup/bin/rustup default stable || failed+=("rustup")

# Skip npm packages published in the last 3 days (written to ~/.npmrc).
# pnpm 11 already waits a day by default.
npm config set min-release-age 3 || failed+=("npm config")

if (( $#failed )); then
    ding
    print -u2 "Finished with failures: ${(j:, :)failed}. Fix them and re-run ./install.sh"
    exit 1
fi

echo "Done. The remaining manual steps are in README.md."
