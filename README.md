# Adam's dotfiles

Personal macOS setup for Python, JS/TS, Docker, Xcode and Android work, managed with plain symlinks. These are highly personalized, so fork and adjust rather than running them as they are.

| Path | What it is |
|---|---|
| `.zprofile` | Login environment and `PATH` |
| `.zshrc`, `.aliases` | Interactive shell |
| `Brewfile` | Packages, apps, Cursor extensions, global CLIs |
| `config/` | git, tmux, mise and starship, linked into `~/.config` |
| `cursor/` | Cursor settings and keybindings |
| `claude/` | Claude Code settings and global `CLAUDE.md`, linked into `~/.claude` |
| `install.sh` | Full setup. Safe to re-run |
| `macOS.sh` | Firewall and system defaults |

## Before wiping a Mac

`install.sh` can't bring any of this back:

- `~/dotfiles/.private`, which is gitignored
- `.env` files, also gitignored: `find ~/Documents -name '.env*' -not -path '*/node_modules/*'`
- Android upload keystores (`*.jks`, `*.keystore`) and iOS signing certs (`.p12`)
- `~/.ssh/config`, `~/.aws/config` and `~/.config/rclone/rclone.conf`
- `~/.claude/skills`, and `~/.claude/projects` for memory and session history
- Local Postgres data (`pg_dumpall`) and named Docker volumes
- Dirty or unpushed work in project repos

## Setting up a new Mac

```sh
git clone https://github.com/adamontherun/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Restore `.private` to `~/dotfiles/.private`, then run:

```sh
./install.sh
```

It asks for your password (firewall and Homebrew), your git name and email, and creates an SSH key if there isn't one. If anything fails it says so at the end, and you can fix it and re-run.

Then finish by hand:

1. Install Xcode from the App Store, then run `sudo xcodebuild -license accept`.
2. Open Android Studio once and install the SDK and its command-line tools.
3. Add `~/.ssh/id_ed25519.pub` to GitHub and the mac mini, and remove the old Mac's key from both.
4. Sign in to `gh`, `aws` and the apps, and copy back anything you saved from the list above.
5. Run `claude` to sign in, reinstall plugins with `/plugin`, and re-add MCP servers with `claude mcp add`. Their tokens live in `~/.claude.json`, which stays out of the repo.

Confirm FileVault is on in System Settings > Privacy & Security.

## Secrets

`.private` is gitignored and sourced by `.zshrc`. Keep it in your password manager as well. Git identity lives in `~/.gitconfig`, which also stays out of the repo, so `config/git/config` only holds shared defaults.

## Languages

| Language | Managed by | Notes |
|---|---|---|
| Python | uv | `uv python install`, `uv venv`, `uv tool install` |
| Node | Homebrew and mise | Brew's `node` is the default. mise switches to a project's `.nvmrc`, `.node-version` or `.tool-versions`, with `mise install` for a missing version |
| Rust | rustup | Keg-only, so `.zprofile` adds it to `PATH` |

mise is set up with `mise activate`, which changes `PATH` directly and doesn't use shims. Databases run in Docker, and `libpq` provides `psql`.

## Keeping things current

The `Brewfile` is hand-maintained and grouped, so don't overwrite it with `brew bundle dump`.

```sh
brew bundle add --file=Brewfile <name>      # add a package
brew bundle cleanup --file=Brewfile         # list installed packages it doesn't mention
```

If an installer replaces a symlink, `.zshrc` warns you. Run `./install.sh --links` to fix it. Any different file gets saved as `<file>.bak`.

Claude Code writes through its symlink, so a settings change shows up in `git status`. Check it before committing, because this repo is public.

## Acknowledgments

Originally forked from [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles), by way of [Corey Schafer's fork](https://github.com/CoreyMSchafer/dotfiles).

## License

MIT, see [LICENSE-MIT.txt](LICENSE-MIT.txt).
