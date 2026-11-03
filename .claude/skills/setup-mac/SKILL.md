---
name: setup-mac
description: Walk someone through setting up a new or wiped Mac with this dotfiles repo, from moving backups across to a final check that everything works. Use when they ask to set up, restore or finish setting up a Mac, or to run install.sh.
---

# Set up a Mac with these dotfiles

You run the commands and checks. The person does anything that needs their password, a license or a sign-in, and anything in System Settings. Tell them exactly what to type or click and wait for them to say it's done. Work through the phases in order, and skip what's already done: every step here is safe to repeat.

## Ground rules

- **Never type or submit a password, 2FA code or recovery key**, even if the person offers one. They type it in their own terminal or browser.
- **Don't run `install.sh` through your own shell.** It needs a real terminal for `sudo`, and stops if it doesn't get one. Have the person run it in Terminal or in the Claude app's terminal panel, which you can read. The script adopts a hand-installed Claude rather than replacing it, so the panel survives the install.
- **Don't read a terminal while it shows secrets**, such as `.private` open in an editor or an `aws` command printing credentials. Ask the person to clear it first.
- **This repo is public.** Before any commit, read `git diff --staged` and keep out account IDs, emails, host and tailnet names, tokens and anything from `.private`. Claude Code and Cursor write their settings through symlinks into this repo, so expect changes you didn't make, and leave them for the person to decide on.
- **Don't create long-lived AWS access keys.** Use `aws login`, below.
- When you give a command with a placeholder, write it so it can't run as is. zsh reads `<host>` as a redirect and fails with a parse error, so say "replace HOST with the other Mac's name" instead.

## 1. Before wiping, on the old Mac

Go through "Before wiping a Mac" in `README.md`. To move the files across, either zip them and AirDrop the zip, or, once Tailscale is up on both Macs, copy them with `scp` over the tailnet. Put `.private` at `~/dotfiles/.private`, not on the Desktop or in Downloads, and remove any stray copies once it's in place.

## 2. Bootstrap

1. The person signs in to the Apple ID, installs Chrome and Claude from the web, and signs in to both. `install.sh` adopts them into Homebrew later.
2. Install the command line tools with `xcode-select --install`. The person clicks through the dialog.
3. Clone over HTTPS with `git clone https://github.com/OWNER/dotfiles.git ~/dotfiles`. There's no SSH key yet, and `install.sh` switches the remote to SSH later.
4. Restore `.private` (see phase 1).

## 3. Run install.sh

The person runs `~/dotfiles/install.sh` in a terminal. It takes 20 to 40 minutes and asks for:

- the login password, once at the start. Touch ID covers any `sudo` prompt after that
- git name and email, if `~/.gitconfig` doesn't have them
- a GitHub sign-in in the browser, with a one-time code shown in the terminal

If you can read the terminal, keep an eye on it and tell the person when it wants them. It ends with either "Done" or a list of failures. For each failure, read the error above it, fix the cause and re-run. Common ones:

| Failure | Fix |
|---|---|
| A pkg cask such as Teams, Zoom or Tailscale | `sudo` expired or there was no terminal. Run `brew install --cask NAME` in a terminal |
| "already an App at /Applications/…" | `brew install --cask --adopt NAME` |
| `gh auth login` | Re-run `install.sh`, or run the same `gh auth login` line from the script |
| `brew bundle` with nothing else listed | Run `brew bundle check --verbose --file=~/dotfiles/Brewfile` to see what's missing |

## 4. Things only the person can unlock

Once these are done, have the person run `install.sh` again. It picks up the Xcode and Android steps.

- **Xcode:** install it from the App Store, which takes a while. The re-run accepts the license, does the first-launch setup and downloads the iOS simulator, about 8 GB.
- **Android Studio:** open it once and finish the Standard setup, which creates `~/Library/Android/sdk`. The re-run adds the command-line tools. Then the person runs `flutter doctor --android-licenses` and accepts each license.
- **Docker Desktop:** open it, accept the terms and approve the helper install with the password.
- **Tailscale:** open it and sign in. If the tailnet needs device approval, the person approves the new Mac in the admin console.
- **System Settings:** grant anything apps ask for (screen recording for Zoom and OBS, accessibility, and so on) when they ask for it.

## 5. Access

- **Other Macs over SSH:** with Tailscale up, `ssh-copy-id -i ~/.ssh/id_ed25519.pub HOST`, using the other Mac's MagicDNS name. The person types that Mac's password. If it fails with "Broken pipe", retry once. Then remove the old Mac's key from that Mac's `~/.ssh/authorized_keys` (back the file up first) and from GitHub (`gh ssh-key list`, then `gh ssh-key delete ID`). Ask which key is the old one rather than guessing from its name.
- **AWS:** `aws login` (AWS CLI 2.32 or later) opens a browser sign-in and caches short-lived credentials. Watch for two problems:
  - It opens in whichever Chrome profile was used last. If the person has several and gets a 400 error, they should copy the URL into the profile that's signed in to the right account, or sign out of the stale session.
  - An IAM user or role needs the `SignInLocalDevelopmentAccess` policy. The root user works without it, but suggest an IAM user for daily use.
  
  Check with `aws sts get-caller-identity`, but don't repeat the account ID anywhere public.
- **Claude Code:** sign in, reinstall plugins with `/plugin` and re-add MCP servers with `claude mcp add`.
- **Apps:** the person signs in to each one. List the casks from the `Brewfile` so nothing gets missed.

## 6. Check everything

Run these and report what passes and what doesn't, with the fix for each failure:

```sh
brew bundle check --verbose --file=~/dotfiles/Brewfile
for f in ~/.zprofile ~/.zshrc ~/.aliases ~/.config/git/config ~/.claude/settings.json ~/.private; do
    [[ $(readlink $f) == $HOME/dotfiles/* ]] || echo "not linked: $f"
done
git config --file ~/.gitconfig user.email
ssh -T git@github.com              # "successfully authenticated", exit code 1 is normal
gh auth status
git -C ~/dotfiles remote get-url origin   # should be git@github.com:…
docker run --rm hello-world
docker run --rm --platform linux/amd64 alpine uname -m   # x86_64, so Rosetta works
xcrun simctl list runtimes | grep iOS
flutter doctor
ls -d ~/.claude/skills/graphify
fdesetup status                    # FileVault is On
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
```

Then have the person run `sudo -k; sudo true` to see the Touch ID prompt.

## 7. Finish

- Log out and back in so the key repeat and trackpad settings from `macOS.sh` apply.
- Set up Time Machine in System Settings > General > Time Machine.
- Install macOS updates. Point releases of the current version are worth taking. A brand-new major version can wait until Xcode, Docker and Android Studio support it.
- Clone the person's project repos over SSH and restore their `.env` files and signing keys from the backup.
- Delete the backup zip and any other copies of secrets once everything is restored.
