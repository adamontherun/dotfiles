# Adam's dotfiles

Personal macOS dotfiles — shell config, VS Code settings, and a Homebrew package list, managed with plain symlinks (no dotfile-manager framework).

## What this manages

- **zsh** (daily-driver shell): `.zshrc`, `.zprofile`, `.zprompt`
- **bash** (minimal fallback — zsh is the real login shell, this just needs to work if something shells out to bash): `.bashrc`, `.bash_profile`, `.bash_prompt`
- **Shared prompt logic**: `.shared_prompt` (sourced by both `.bash_prompt` and `.zprompt`)
- **Aliases**: `.aliases`
- **Homebrew packages/casks/VS Code extensions/npm & uv globals**: `Brewfile`
- **VS Code settings/keybindings**: `settings/VSCode-Settings.json`, `settings/VSCode-Keybindings.json`
- **A few macOS system defaults**: `macOS.sh` (Finder show-all-files/extensions, Xcode CLI tools, Rosetta)

This repo does **not** manage: git identity (`~/.gitconfig` — `brew.sh` prompts for name/email once, only if unset), any secrets (see `.private` below), Cursor's settings (installed, but unmanaged here), or Docker Desktop/Xcode app-level preferences.

## Fresh-machine bootstrap

Prerequisite: Xcode Command Line Tools (`macOS.sh` triggers `xcode-select --install` if they're missing — that's the only thing that has to happen before `install.sh` can run; Homebrew itself is bootstrapped by `brew.sh` if it isn't already installed).

```sh
git clone https://github.com/adamontherun/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

This symlinks the dotfiles into `$HOME`, runs `macOS.sh`, installs everything in `Brewfile` via `brew bundle`, and symlinks the VS Code settings.

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

Review the diff before committing — this will pick up anything installed outside of a deliberate "I want this on every machine" decision too.

## Known footguns

- **The `test` alias shadows the `test`/`[` builtin.** `.aliases` defines `alias test='pytest -p no:warnings'`, so in any interactive shell, `test -e some/path` runs pytest, not the builtin. Use `command test` or `[[ ... ]]` instead.
- **Some installers silently break the managed symlinks.** A few CLI tools "safe-save" to `~/.zshrc`/`~/.aliases`/VS Code's `settings.json` by writing a temp file and renaming it over the original — this replaces the symlink with a disconnected regular file, so edits stop round-tripping to this repo. If changes here stop taking effect (or vice versa), run `ls -la` on the file in question; if it's no longer a `-> ~/dotfiles/...` symlink, re-run the relevant `ln -sf` from `install.sh` (or `vscode.sh` for the VS Code files).

## Acknowledgments

Originally forked from [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles), by way of [Corey Schafer's fork](https://github.com/CoreyMSchafer/dotfiles).

## License

MIT — see [LICENSE-MIT.txt](LICENSE-MIT.txt).
