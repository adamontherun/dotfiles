# Adam's dotfiles

Personal macOS dotfiles — shell config, VS Code settings, and a Homebrew package list, managed with plain symlinks (no dotfile-manager framework).

**Note:** these are **highly personalized**. If you found this by way of the fork chain below, I'd encourage forking and adjusting rather than running it as-is — it will modify your shell config, macOS defaults, and installed software.

## What this manages

zsh only — it's the only shell I use interactively, so there's no bash config to keep in sync.

- **zsh**: `.zshrc`, `.zprofile`
- **Prompt**: [Starship](https://starship.rs) (`starship.toml`), config-driven instead of hand-rolled shell scripting
- **Aliases**: `.aliases`
- **Homebrew packages/casks/VS Code extensions/npm & uv globals**: `Brewfile`
- **VS Code settings/keybindings**: `settings/VSCode-Settings.json`, `settings/VSCode-Keybindings.json`
- **macOS system defaults**: `macOS.sh` (Finder, Dock, keyboard repeat rate, screenshot location, scroll direction, Xcode CLI tools, Rosetta)
- **Symlink health**: `check-symlinks.sh` runs quietly at the start of every login shell (via `.zprofile`) and auto-repairs any managed dotfile whose symlink got silently replaced by a regular file with identical content — see below.

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

It's sourced automatically by `.zshrc`.

## Updating the Brewfile

`Brewfile` is a snapshot of actually-installed formulae, casks, VS Code extensions, and npm/uv globals — not a hand-maintained wishlist. To refresh it after installing or removing something:

```sh
cd ~/dotfiles
brew bundle dump --file=Brewfile --force
```

Review the diff before committing — this will pick up anything installed outside of a deliberate "I want this on every machine" decision too.

## Language toolchains

`asdf` was removed on 2026-07-20. Its shims sat first on `PATH` and silently shadowed real binaries — it broke `uv` outright and pinned Claude Code to a stale npm copy — and no project here ever used a `.tool-versions` file, so per-project switching bought nothing. One tool per language now:

| Language | Managed by | Notes |
|---|---|---|
| Python | **uv** | `uv python install`, `uv venv`, `uv tool install`. Never `pip install` into a Homebrew interpreter. |
| Node | **Homebrew** | `brew "node"`. Use `fnm` or `volta` if per-project versions are ever needed — not asdf. |
| Ruby | **Homebrew** | `brew "ruby"`. Needs `brew link ruby`; the system Ruby is ancient. |
| Rust | **rustup** | `brew "rustup"`, then `rustup default stable`. Keg-only, so `.zshrc` adds `/opt/homebrew/opt/rustup/bin` to `PATH`. |

These four are in the Brewfile, so a rebuilt machine gets the whole toolchain.

## macOS preferences (`macOS.sh`)

- Finder: show all file extensions, show hidden files
- Dock: auto-hide, no delay
- Keyboard: faster key repeat rate, shorter initial delay
- Screenshots saved to `~/Desktop/Screenshots`
- Natural scroll direction disabled
- Bluetooth icon shown in the menu bar

## Acknowledgments

Originally forked from [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles), by way of [Corey Schafer's fork](https://github.com/CoreyMSchafer/dotfiles).

## License

MIT — see [LICENSE-MIT.txt](LICENSE-MIT.txt).
