#!/usr/bin/env zsh
# Sets up this Mac. Safe to re-run, and worth re-running after installing Xcode
# and opening Android Studio once, since each unlocks a few more steps.
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

# An app installed by hand, like the Chrome and Claude it took to get here,
# makes its cask fail. Adopt it instead. For casks that update themselves this
# keeps the app as it is, so a running Claude isn't replaced mid-install.
adopt_casks() {
    local cask app
    local -a casks
    casks=(${(f)"$(grep -o '^cask "[^"]*"' "$dotfiles/Brewfile" | cut -d'"' -f2)"})
    # Prints each missing cask's token and app name on alternate lines.
    for cask app in ${(f)"$(brew info --json=v2 --cask $casks | /usr/bin/jq -r '
        .casks[] | select(.installed == null) | .token as $t
        | .artifacts[] | .app? // empty | .[] | strings | $t, .')"}; do
        [[ -e /Applications/$app ]] || continue
        brew install --cask --adopt "$cask" </dev/null || failed+=("$cask")
    done
}

# Android Studio's first launch creates the SDK but leaves out the command-line
# tools that flutter needs. Fetch the current release from Google's index.
install_android_cmdline_tools() {
    local sdk=$1 repo=https://dl.google.com/android/repository tmp url sha
    local xpath="//remotePackage[@path='cmdline-tools;latest']//archive[host-os='macosx']/complete"
    tmp=$(mktemp -d)
    curl -fsSL "$repo/repository2-1.xml" -o "$tmp/repo.xml" || return
    url=$(xmllint --xpath "string($xpath/url)" "$tmp/repo.xml") || return
    sha=$(xmllint --xpath "string($xpath/checksum)" "$tmp/repo.xml") || return
    curl -fL "$repo/$url" -o "$tmp/tools.zip" || return
    [[ $(shasum -a 1 "$tmp/tools.zip") == "$sha "* ]] || { echo "Checksum mismatch for $url"; return 1; }
    unzip -q "$tmp/tools.zip" -d "$tmp" || return
    mkdir -p "$sdk/cmdline-tools"
    mv "$tmp/cmdline-tools" "$sdk/cmdline-tools/latest"
    rm -rf "$tmp"
}

if [[ ${1:-} == --links ]]; then
    link_all
    exit
fi

if [[ ! -t 0 ]]; then
    print -u2 "Run this in a terminal. It asks for your password and opens sign-ins."
    exit 1
fi

# Rosetta, the firewall and Homebrew's pkg installers need sudo, and the run
# outlasts its timeout. Ask once, then keep it fresh until this script exits.
sudo -v
while kill -0 $$ 2>/dev/null; do sudo -n -v 2>/dev/null || true; sleep 50; done &
trap "kill $! 2>/dev/null" EXIT

"$dotfiles/macOS.sh"

# Homebrew. NONINTERACTIVE skips its "Press RETURN" and uses the sudo above.
if [[ ! -x /opt/homebrew/bin/brew ]]; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

adopt_casks

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
fi

# GitHub. Sign in through the browser, then upload the key with `gh ssh-key add`
# rather than gh's own prompt for it.
if ! gh auth status &>/dev/null; then
    ding
    gh auth login --hostname github.com --git-protocol ssh --web --skip-ssh-key || failed+=("gh auth login")
fi
if gh auth status &>/dev/null; then
    if ! gh ssh-key list 2>/dev/null | grep -qF "$(cut -d' ' -f2 ~/.ssh/id_ed25519.pub)"; then
        gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(scutil --get ComputerName)" || failed+=("gh ssh-key add")
    fi
    ssh -o StrictHostKeyChecking=accept-new -T git@github.com 2>/dev/null || true
fi

# This repo was cloned over HTTPS to get here. Push over SSH from now on.
origin=$(git -C "$dotfiles" remote get-url origin)
if [[ $origin == https://github.com/* ]]; then
    git -C "$dotfiles" remote set-url origin "git@github.com:${origin#https://github.com/}"
fi

# Toolchains
mkdir -p ~/.terraform.d/plugin-cache
/opt/homebrew/opt/rustup/bin/rustup default stable || failed+=("rustup")

# Skip npm packages published in the last 3 days (written to ~/.npmrc).
# pnpm 11 already waits a day by default.
npm config set min-release-age 3 || failed+=("npm config")

# The global CLAUDE.md relies on the graphify skill, which lives outside this repo.
if [[ -x ~/.local/bin/graphify && ! -d ~/.claude/skills/graphify ]]; then
    ~/.local/bin/graphify install --platform claude || failed+=("graphify skill")
fi

# Xcode comes from the App Store, so this runs on the first pass after it's in.
if [[ -d /Applications/Xcode.app ]]; then
    if [[ $(xcode-select -p) != /Applications/Xcode.app/* ]]; then
        sudo xcode-select -s /Applications/Xcode.app
    fi
    xcodebuild -license check &>/dev/null || sudo xcodebuild -license accept
    xcodebuild -checkFirstLaunchStatus || sudo xcodebuild -runFirstLaunch
    if ! xcrun simctl list runtimes | grep -q '^iOS'; then
        xcodebuild -downloadPlatform iOS || failed+=("iOS simulator")
    fi
fi

android_sdk=~/Library/Android/sdk
if [[ -d $android_sdk && ! -d $android_sdk/cmdline-tools/latest ]]; then
    install_android_cmdline_tools "$android_sdk" || failed+=("Android cmdline-tools")
fi

if (( $#failed )); then
    ding
    print -u2 "Finished with failures: ${(j:, :)failed}. Fix them and re-run ./install.sh"
    exit 1
fi

echo "Done. The remaining manual steps are in README.md."
