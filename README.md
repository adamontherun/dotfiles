# Adam's dotfiles

Personal macOS dotfiles — shell config, VS Code settings, and a Homebrew package list, managed with plain symlinks (no dotfile-manager framework).

**Note:** these are **highly personalized**. If you found this by way of the fork chain below, I'd encourage forking and adjusting rather than running it as-is — it will modify your shell config, macOS defaults, and installed software.

## What this manages

- **zsh** (daily-driver shell): `.zshrc`, `.zprofile`, `.zprompt`
- **bash** (minimal fallback — zsh is the real login shell, this just needs to work if something shells out to bash): `.bashrc`, `.bash_profile`, `.bash_prompt`
- **Shared prompt logic**: `.shared_prompt` (sourced by both `.bash_prompt` and `.zprompt`)
- **Aliases**: `.aliases`
- **Homebrew packages/casks/VS Code extensions/npm & uv globals**: `Brewfile`
- **VS Code settings/keybindings**: `settings/VSCode-Settings.json`, `settings/VSCode-Keybindings.json`
- **macOS system defaults**: `macOS.sh` (Finder, Dock, keyboard repeat rate, screenshot location, scroll direction, Xcode CLI tools, Rosetta)

This repo does **not** manage Cursor's settings (installed, but unmanaged here) or Docker Desktop/Xcode app-level preferences.

## Fresh-machine bootstrap

Prerequisite: Xcode Command Line Tools (`macOS.sh` triggers `xcode-select --install` if they're missing — that's the only thing that has to happen before `install.sh` can run; Homebrew itself is bootstrapped by `brew.sh` if it isn't already installed).

```sh
git clone https://github.com/adamontherun/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

This symlinks the dotfiles into `$HOME`, runs `macOS.sh`, installs everything in `Brewfile` via `brew bundle` and sets Homebrew's zsh as the default shell, then symlinks the VS Code settings. Along the way it will prompt you to:
- enter your name/email for git (skipped if already set)
- generate an SSH key for GitHub if you don't have one at `~/.ssh/id_ed25519` (prints the public key to add to GitHub)

It also sets a few git defaults: `init.defaultBranch main`, `pull.rebase false`, `core.editor "code --wait"`.

## Secrets (`.private`)

`.private` is gitignored and never committed. On a fresh machine, create it by hand (values live in your password manager, not here):

```sh
export GIPHY_API_KEY='...'
export KLIPY_API_KEY='...'
```

It's sourced automatically by both `.zshrc` and `.bashrc`.

## Updating the Brewfile

`Brewfile` is a snapshot of actually-installed formulae, casks, VS Code extensions, and npm/uv globals — not a hand-maintained wishlist. To refresh it after installing or removing something:

```sh
cd ~/dotfiles
brew bundle dump --file=Brewfile --force
```

Review the diff before committing — this will pick up anything installed outside of a deliberate "I want this on every machine" decision too. Language versions themselves (Python/Node/Ruby/Rust) aren't in the Brewfile — they're managed by `asdf` and pinned in `~/.tool-versions`.

## macOS preferences (`macOS.sh`)

- Finder: show all file extensions, show hidden files
- Dock: auto-hide, no delay
- Keyboard: faster key repeat rate, shorter initial delay
- Screenshots saved to `~/Desktop/Screenshots`
- Natural scroll direction disabled
- Bluetooth icon shown in the menu bar

## Known footguns

- **The `test` alias shadows the `test`/`[` builtin.** `.aliases` defines `alias test='pytest -p no:warnings'`, so in any interactive shell, `test -e some/path` runs pytest, not the builtin. Use `command test` or `[[ ... ]]` instead.
- **Some installers silently break the managed symlinks.** A few CLI tools "safe-save" to `~/.zshrc`/`~/.aliases`/VS Code's `settings.json` by writing a temp file and renaming it over the original — this replaces the symlink with a disconnected regular file, so edits stop round-tripping to this repo. If changes here stop taking effect (or vice versa), run `ls -la` on the file in question; if it's no longer a `-> ~/dotfiles/...` symlink, re-run the relevant `ln -sf` from `install.sh` (or `vscode.sh` for the VS Code files).

## Acknowledgments

Originally forked from [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles), by way of [Corey Schafer's fork](https://github.com/CoreyMSchafer/dotfiles).

## License

MIT — see [LICENSE-MIT.txt](LICENSE-MIT.txt).
