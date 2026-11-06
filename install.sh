#!/bin/sh
# Bootstrap for Linux (apt) and macOS (brew): pick GUI or headless, install base
# packages, install chezmoi, apply. Windows: see README.
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/noahm-05/dotfiles/main/install.sh)"
# Skip the menu: DOTFILES_GUI=1 (GUI) or DOTFILES_GUI=0 (headless).
set -eu

REPO=https://github.com/noahm-05/dotfiles.git
SRC=$HOME/.local/share/chezmoi
KEY_FPR=EA0F721D231FDD3A0A17B9AC7808B4DD62C41256

if [ -z "${DOTFILES_GUI:-}" ]; then
  printf '\nInstall type:\n  1) GUI machine (Ghostty, font, tinty)\n  2) Headless (server, VM, LXC)\n\nChoose [1/2]: '
  read -r c </dev/tty
  case $c in 1) DOTFILES_GUI=1 ;; 2) DOTFILES_GUI=0 ;; *) echo "Enter 1 or 2" >&2; exit 1 ;; esac
fi
[ "$DOTFILES_GUI" = 1 ] && GUI=true || GUI=false

mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

case $(uname -s) in
Linux)
  command -v apt-get >/dev/null || { echo "Only apt-based Linux is supported here" >&2; exit 1; }
  sudo apt-get update
  sudo apt-get install -y git curl
  ;;
Darwin)
  command -v brew >/dev/null || { echo "Install Homebrew first: https://brew.sh" >&2; exit 1; }
  brew install git chezmoi
  ;;
*) echo "Unsupported OS (Windows: see README)" >&2; exit 1 ;;
esac

command -v chezmoi >/dev/null || curl -fsSL https://get.chezmoi.io | sh -s -- -b "$HOME/.local/bin"
chezmoi init --promptBool "GUI machine (Ghostty, tinty, font)=$GUI" "$REPO"

if [ "$(uname -s)" = Darwin ]; then
  brew bundle --file "$SRC/packages/Brewfile"
  [ "$GUI" = true ] && brew bundle --file "$SRC/packages/Brewfile.gui"
else
  xargs -a "$SRC/packages/apt.txt" sudo apt-get install -y
  if [ "$GUI" = true ]; then
    # Ghostty is not in Debian: griffo.io free mirror, key fingerprint checked before trusting it
    sudo apt-get install -y gpg
    curl -fsSL "https://deb-free.griffo.io/$KEY_FPR.asc" -o /tmp/griffo.asc
    gpg --show-keys --with-colons /tmp/griffo.asc | grep -q "^fpr:::::::::$KEY_FPR:" \
      || { echo "griffo.io key fingerprint mismatch, aborting" >&2; exit 1; }
    sudo install -d -m 0755 /etc/apt/keyrings
    sudo gpg --dearmor --yes -o /etc/apt/keyrings/deb-free.griffo.io.gpg /tmp/griffo.asc
    echo "deb [signed-by=/etc/apt/keyrings/deb-free.griffo.io.gpg] https://deb-free.griffo.io/apt $(. /etc/os-release; echo "$VERSION_CODENAME") main" \
      | sudo tee /etc/apt/sources.list.d/deb-free.griffo.io.list >/dev/null
    sudo apt-get update
    sudo apt-get install -y ghostty
  fi
fi

chezmoi apply
[ "$GUI" = true ] && command -v fc-cache >/dev/null && fc-cache -f
chsh -s "$(command -v zsh)" || echo "Run 'chsh -s $(command -v zsh)' yourself to make zsh your login shell"
echo "Done. Log out and back in to start zsh."
