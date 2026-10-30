# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:/Users/adamsmith/.docker/bin"
# End of Docker Desktop section.

# Login environment. PATH lives here, not in .zshenv, because macOS's
# /etc/zprofile runs path_helper after .zshenv and would reorder it.
eval "$(/opt/homebrew/bin/brew shellenv)"

export ANDROID_HOME="$HOME/Library/Android/sdk"
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
export AWS_PROFILE=betaacid

# rustup is keg-only, so Homebrew doesn't link it.
path=(
    "$HOME/.local/bin"
    /opt/homebrew/opt/rustup/bin
    "$ANDROID_HOME"/{platform-tools,emulator,cmdline-tools/latest/bin}
    $path
)

# Keep this last: drop duplicates and directories that don't exist.
typeset -U path
path=($^path(N-/))
