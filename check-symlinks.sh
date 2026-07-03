#!/usr/bin/env zsh
############################
# Some CLI installers "safe-save" config files (write to a temp file,
# then rename it over the original). If the original was a symlink into
# this repo, that rename silently replaces it with a disconnected
# regular file — edits stop round-tripping to the repo with no error.
#
# This script detects that. With --fix, it also auto-repairs any case
# where the stray file's content is byte-identical to the repo's copy
# (safe: nothing is lost). If content differs, it only warns — that
# means real, un-backed-up edits have accumulated and need a human to
# reconcile them, not an automatic overwrite.
############################

dotfiledir="$(cd "$(dirname "$0")" && pwd)"
files=(zshrc zprofile zprompt bashrc bash_profile bash_prompt aliases private)

quiet=false
fix=false
for arg in "$@"; do
    [[ "$arg" == "--quiet" ]] && quiet=true
    [[ "$arg" == "--fix" ]] && fix=true
done

problems=0

check_pair() {
    local target="$1" source="$2" label="$3"

    [ -e "$source" ] || return

    if [ -L "$target" ]; then
        local linked_to
        linked_to="$(readlink "$target")"
        if [ "$linked_to" != "$source" ]; then
            echo "warn: $label is a symlink, but points to $linked_to, not $source"
            problems=$((problems + 1))
        fi
        return
    fi

    [ -e "$target" ] || return

    if diff -q "$target" "$source" &>/dev/null; then
        if $fix; then
            ln -sf "$source" "$target"
            echo "fixed: $label was a disconnected copy (identical content) — relinked to $source"
        else
            echo "warn: $label is a regular file, not a symlink to $source"
            echo "      contents match the repo copy — safe to relink with: ln -sf \"$source\" \"$target\""
        fi
        problems=$((problems + 1))
    else
        echo "warn: $label is a regular file, not a symlink to $source"
        echo "      contents DIFFER from the repo copy — resolve by hand (diff \"$target\" \"$source\"), do not blindly relink"
        problems=$((problems + 1))
    fi
}

for file in "${files[@]}"; do
    check_pair "$HOME/.${file}" "${dotfiledir}/.${file}" "~/.${file}"
done

VSCODE_USER_SETTINGS_DIR="${HOME}/Library/Application Support/Code/User"
check_pair "${VSCODE_USER_SETTINGS_DIR}/settings.json" "${dotfiledir}/settings/VSCode-Settings.json" "VS Code settings.json"
check_pair "${VSCODE_USER_SETTINGS_DIR}/keybindings.json" "${dotfiledir}/settings/VSCode-Keybindings.json" "VS Code keybindings.json"

if [ "$problems" -eq 0 ]; then
    $quiet || echo "All managed dotfiles are correctly symlinked."
fi

exit 0
